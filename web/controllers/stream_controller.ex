defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf
  require Logger

  def index(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20}, %{ttl: 3600})

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

    games = RestTwitch.Games.top(%{"limit" => 20}, %{ttl: 3600})
    streams = RestTwitch.Users.streams(token.access_token, Map.merge(defaults, params))
      |> Map.fetch!("streams")
      |> Enum.map(fn (stream) ->
        TwitchDiscovery.Indexer.Stream.process(stream)
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


  def index2(conn, params) do
    index = TwitchDiscovery.Index.get_current_index()
    # {:ok, mongo} = Mongo.Connection.start_link(database: "discovery")

    collection = "streams-" <> index

    Logger.debug "Querying: #{collection}"

    query = %{
      "$query" => TwitchDiscovery.BroadcastController.parse_params_to_query(params),
      "$orderby" => TwitchDiscovery.BroadcastController.sorting(params)
    }

    IO.puts Poison.encode!(query)
    IO.inspect query

    streams = Mongo.find(MongoPool, collection, query, limit: 24)
    |> Enum.to_list
    |> Enum.map(fn (result) ->
      key = TwitchDiscovery.Parser.Stream.db_key(result["id"])

      IO.inspect key

      result = key
      |> TwitchDiscovery.Index.redis_get()

      case result do
        :undefined -> IO.inspect "no redis"; nil
        result -> result |> Poison.decode!()
      end
    end)

    # broadcasts = Enum.to_list results

    render conn, "streams_filtered.html", streams: streams, params: params
  end
end
