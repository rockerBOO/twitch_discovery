defmodule TwitchDiscovery.UserController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def follow(conn, %{"channel" => channel}) do
    user  = get_session(conn, :current_user)
    token = get_session(conn, :access_token)

    result = RestTwitch.Follows.follow(token.access_token, user["name"], channel)

    IO.inspect result
  end
end
