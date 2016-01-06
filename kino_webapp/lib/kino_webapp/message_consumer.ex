defmodule KinoWebapp.MessageConsumer do
  use GenServer
  use AMQP
  import Ecto.Query

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @queue       "file_created"
  @queue_error "#{@queue}_error"
  @exchange    ""

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@rabbitmq.local:5672")
    {:ok, chan} = Channel.open(conn)
    Basic.qos(chan, prefetch_count: 10)
    Queue.declare(chan, @queue, durable: true)

    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_cancel, %{consumer_tag: consuemr_tag}}, chan) do
    {:stop, :normal, chan}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: consuemr_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: delivery_tag, redelivered: redelivered}}, chan) do
    %{"contents" => contents, "path" => file_path, "name" => file_name} = Poison.decode!(payload)
    full_file_name = Path.join(file_path, file_name)
    user = find_or_create_user_automatically(file_path)
    post = %KinoWebapp.Post{:content => contents, :key => full_file_name, :user_id => user.id}
    KinoWebapp.Repo.insert!(post)

    Basic.ack(chan, delivery_tag)
    {:noreply, chan}
  end

  # suuuuper temporary. only for the benefit of #11
  defp find_or_create_user_automatically(file_path) do
    [_, username] = Regex.run(~r/\/home\/([^\/]+)/, file_path)

    user = KinoWebapp.User
           |> where(username: ^username)
           |> KinoWebapp.Repo.one
    user || create_user(username)
  end

  defp create_user(username) do
    user = %KinoWebapp.User{:username => username}
    KinoWebapp.Repo.insert!(user)
  end
end
