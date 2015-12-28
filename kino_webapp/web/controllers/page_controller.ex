defmodule KinoWebapp.PageController do
  use KinoWebapp.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
