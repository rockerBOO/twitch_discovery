defmodule TwitchDiscovery.UserController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end