defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf
  require Logger

  alias   TwitchDiscovery.Index.Stream
  alias   TwitchDiscovery.Index.Game
  alias   TwitchDiscovery.Index

  def streams(params) do
    streams = Stream.params_to_query(params)
    |> Stream.find(limit: 24)
  end

  def streams_json(conn, params) do
    IO.inspect params

    render conn, streams: streams(params)
  end

  def live_streams(conn, params) do
    streams = streams(params)

    render conn, "streams.html", streams: streams
  end

  def following(conn, params) do
    token = get_session(conn, :access_token)

    defaults = %{"limit" => 24}

    streams = RestTwitch.Users.streams(token.access_token, Map.merge(defaults, params))
    |> Map.fetch!("streams")

    render conn, "streams.html", streams: streams
  end

  def summary(conn, params) do
    summary = RestTwitch.Streams.summary(params, %{ttl: 60})

    render conn, "summary.html",
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
