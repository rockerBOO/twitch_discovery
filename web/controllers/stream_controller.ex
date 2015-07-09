defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf

  plug :action

  def index(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20}, %{ttl: 3600})

    defaults = %{"limit" => 24}

    streams = RestTwitch.Streams.live(Map.merge(defaults, params), %{ttl: 60})
      |> Enum.map(fn (stream) ->
        TwitchDiscovery.Indexer.Stream.process(stream)
        stream
      end)

    render conn, "streams.html", streams: streams, games: games
  end

  def following(conn, params) do
    token = get_session(conn, :access_token)

    defaults = %{"limit" => 24}

    games = RestTwitch.Games.top(%{"limit" => 20}, %{ttl: 3600})
    streams = RestTwitch.Users.streams(token.access_token, Map.merge(defaults, params))
      |> Map.fetch!("streams")
      |> Enum.map(fn (stream) ->
        # TwitchDiscovery.Indexer.Stream.process(stream)
        stream
      end)

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
