defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf
  require Logger

  alias   TwitchDiscovery.Index.Stream
  alias   TwitchDiscovery.Index.Game
  alias   TwitchDiscovery.Index

  @limit 24

  def streams(params, opts \\ []) do
    streams = Stream.params_to_query(params)
    |> Stream.find(opts)
  end

  def streams_json(conn, params) do
    IO.inspect params

    render conn, streams: streams(params, filter_opts(params))
  end

  def live_streams(conn, params) do
    streams = streams(params, filter_opts(params))

    render conn, "streams.html", streams: streams, page_title: "Livestreams - Discovery"
  end

  def following(conn, params) do
    token = get_session(conn, :access_token)

    defaults = %{"limit" => @limit}

    streams = RestTwitch.Users.streams(token.access_token, Map.merge(defaults, params))
    |> Map.fetch!("streams")

    render conn, "streams.html", streams: streams
  end

  # def summary(conn, params) do
  #   summary = RestTwitch.Streams.summary(params, %{ttl: 60})

  #   render conn, "summary.html",
  #     viewers: summary["viewers"],
  #     channels: summary["channels"]
  # end

  def to_int(x) when is_integer(x), do: x
  def to_int(string) do
    {int, _} = Integer.parse(string)

    int
  end

  def filter_opts(params) do
    offset = Map.get(params, "offset", 0) |> to_int

    [limit: @limit]
    |> Keyword.put(:skip, offset)
  end

  def index(conn, params) do
    streams = streams(params, filter_opts(params))

    render conn, "streams_filtered.html",
      streams: streams, params: params, limit: @limit, page_title: "Livestreams - Discovery"

  end
end
