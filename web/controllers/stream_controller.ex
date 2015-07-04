defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf

  def index(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20})

    streams = RestTwitch.Streams.live(params)

    render conn, "streams.html", streams: streams, games: games
  end

  def summary(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20})

    summary = RestTwitch.Streams.summary(params)

    IO.inspect summary

    render conn, "summary.html",
      games: games,
      viewers: summary["viewers"],
      channels: summary["channels"]
  end
end
