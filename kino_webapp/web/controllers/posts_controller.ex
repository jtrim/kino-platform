defmodule KinoWebapp.PostsController do
  use KinoWebapp.Web, :controller
  import Ecto.Query

  def index(conn, params) do
    user = get_user(params)
    render conn, "index.html", user: user, posts: user.posts
  end

  defp get_user(params) do
    %{"users_id" => user_id} = params
    KinoWebapp.User
    |> preload(:posts)
    |> KinoWebapp.Repo.get(user_id)
  end
end
