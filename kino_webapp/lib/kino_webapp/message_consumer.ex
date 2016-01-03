defmodule KinoWebapp.MessageConsumer do
  use GenServer
  use AMQP

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
    post = %KinoWebapp.Post{:content => contents, :key => full_file_name}
    KinoWebapp.Repo.insert!(post)

    Basic.ack(chan, delivery_tag)
    {:noreply, chan}
  end
end
