defmodule TwitchDiscovery.UserController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def follow(conn, %{"channel" => channel}) do
    user  = get_session(conn, :current_user)
    token = get_session(conn, :access_token)

    result = RestTwitch.Follows.follow(token.access_token, user["name"], channel)
      |> RestTwitch.Follows.get_list("channel")

    json conn, %{status: "ok"}
  end

  def follows(conn, %{"channel" => channel}) do
    user  = get_session(conn, :current_user)
    follows = RestTwitch.Follows.follows(user["name"], channel)

    IO.inspect follows

    case follows do
      %{"created_at" => _} -> json conn, %{status: "ok"}
      # value -> json conn, %{status: "ok", result: value}
      _ ->json conn, %{status: "error"}
    end
  end
end
