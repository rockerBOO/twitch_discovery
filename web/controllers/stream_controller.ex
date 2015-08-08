defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf
  require Logger

  alias   TwitchDiscovery.Index.Stream
  alias   TwitchDiscovery.Index.Game
  alias   TwitchDiscovery.Index

  def live_streams(conn, params) do
    games = Game.format_query(%{}, %{"channel" => 1})
    |> Game.find(limit: 24)

    defaults = %{"limit" => 24}

    streams = RestTwitch.Streams.live(Map.merge(defaults, params), %{ttl: 60})
      |> Map.fetch!("streams")
      |> Enum.map(fn (stream) ->
        stream
      end)

    render conn, "streams.html", streams: streams, games: games
  end

  def following(conn, params) do
    token = get_session(conn, :access_token)

    defaults = %{"limit" => 24}

    streams = RestTwitch.Users.streams(token.access_token, Map.merge(defaults, params))
      |> Map.fetch!("streams")

    render conn, "streams.html", streams: streams
  end

  def summary(conn, params) do
    games = Game.format_query(%{}, %{"channel" => 1})
    |> Game.find(limit: 24)

    summary = RestTwitch.Streams.summary(params, %{ttl: 60})

    # IO.inspect summary

    render conn, "summary.html",
      games: games,
      viewers: summary["viewers"],
      channels: summary["channels"]
  end


  def index(conn, params) do
    IO.puts "Current Index: #{Stream.get_current_index("stream")}"

    streams = Stream.params_to_query(params)
    |> Stream.find(limit: 24)

    render conn, "streams_filtered.html", streams: streams, params: params
  end
end
