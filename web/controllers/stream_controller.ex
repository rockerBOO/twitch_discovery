defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf

  def index(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 100}, %{ttl: 3600})

    streams = RestTwitch.Streams.live(params, %{ttl: 60})

    render conn, "streams.html", streams: streams, games: games
  end

  def summary(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20}, %{ttl: 3600})

    summary = RestTwitch.Streams.summary(params, %{ttl: 60})

    # IO.inspect summary

    render conn, "summary.html",
      games: games,
      viewers: summary["viewers"],
      channels: summary["channels"]
  end
end
