defmodule TwitchDiscovery.UserController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def follow(conn, %{"channel" => channel}) do
    user  = get_session(conn, :current_user)
    token = get_session(conn, :access_token)

    result = RestTwitch.Follows.follow(token.access_token, user["name"], channel)

    json conn, %{status: "ok"}
  end

  def follows(conn, %{"channel" => channel}) do
    user  = get_session(conn, :current_user)

    case RestTwitch.Follows.follows(user["name"], channel) do
      %{"created_at": _} -> json conn, %{status: "ok"}
      _ ->json conn, %{status: "error"}
    end
  end
end
