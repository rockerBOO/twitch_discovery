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
        spawn(fn () ->
            TwitchDiscovery.Indexer.Stream.process("live-streams", stream)
        end)
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
    index = TwitchDiscovery.Indexer.Stream.get_current_index()

    Logger.debug "Querying data from broadcasts-" <> Integer.to_string(index)

    # {:ok, mongo} = Mongo.Connection.start_link(database: "discovery")

    collection = "streams-" <> Integer.to_string(index)

    query = %{
      "$query" => TwitchDiscovery.BroadcastController.parse_params_to_query(params),
      "$orderby" => TwitchDiscovery.BroadcastController.sorting(params)
    }

    IO.inspect query

    broadcasts = Mongo.find(MongoPool, collection, query, limit: 24)
      |> Enum.to_list
      |> Enum.map(fn (result) ->
          TwitchDiscovery.Indexer.Stream.db_key(result["id"])
            |> TwitchDiscovery.Indexer.Stream.redis_get()
            |> Poison.decode!()
        end)
      # |> IO.inspect

    # broadcasts = Enum.to_list results

    render conn, "broadcasts.html", broadcasts: broadcasts, params: params
  end
end
