defmodule TwitchDiscovery.Indexer.Broadcast do
  alias TwitchDiscovery.Indexer
  use TwitchDiscovery.IndexBase
  require Logger
  use Timex
  require Logger

  def db_key(id) do
    "td-broadcast-" <> Integer.to_string(id)
  end

  def db_key(id, field) do
    "td-broadcast-" <> Integer.to_string(id) <> "-" <> field
  end

  # HashSet for captured fields
  def generate_hash_set(captured_fields) do
    broadcast_id = captured_fields.id
    modified     = HashSet.new

    # Process captured filters
    # [{"language", stream["channel"]["broadcaster_language"]},..]
    modified = captured_fields.filters
      |> Enum.reduce(modified, fn ({key, value}, modified) ->
        HashSet.put(modified, {String.to_atom(key), value})
      end)
      |> IO.inspect

    # Pass in previous modified and apply meta data
    modified = captured_fields.meta
      |> Enum.reduce(modified, fn ({key, value}, modified) ->
        HashSet.put(modified, {String.to_atom(key), value})
      end)

    captured_fields.metrics
      |> Enum.reduce(modified, fn ({key, value}, modified) ->
        HashSet.put(modified, {String.to_atom(key), value})
      end)
  end

  def convert_hash_set_to_map(hash_set) do
    hash_set
      |> Enum.reduce(%{}, fn ({key, value}, acc) ->
        Map.merge(acc, Map.put(%{}, key, value))
      end)
  end

  def save(data, id) do
    key   = db_key(id)
    redis = :redis_client |> Process.whereis()

    Logger.debug "Sending json data to #{key} on Redis"

    redis |> Exredis.query(["SETEX", key, 86400, Poison.encode!(data)])
  end

  def redis_client() do
    :redis_client
      |> Process.whereis()
  end

  def redis_get(key) do
    redis_client()
      |> Exredis.query(["GET", key])
  end

  def get_current_index() do
    case redis_get("broadcast_index") do
      :undefined -> 0
      index -> index
    end
  end

  def get_processing_index() do
    case redis_get("broadcast_index") do
      2 -> 0
      1 -> 2
      0 -> 1
    end
  end

  def mongo_save(data, id) do
    index = get_current_index()

    Logger.debug "Saving to broadcasts-#{index}"
    IO.inspect data


    # {:ok, mongo} = Mongo.Connection.start_link(database: "discovery")


    collection = "broadcasts-" <> Integer.to_string(index)

    try do
      Mongo.insert_one(MongoPool, collection, data)
    rescue
      e in Mongo.Error -> e
    end
  end


  # ## Meta
  #   broadcast_id = {broadcast, stream["_id"]}
  #   titles = {channel, ["4v1 4HP Clutch", "Minecon 2015 - Main Stream"]}

  def id(stream) do
    stream["_id"]
  end

  def meta(stream) do
    [{"id", id(stream)},
     {"title", stream["title"]}]
  end

  # ## Filters
  #   channel = {broadcast, "rockerboo"}
  #   game = {broadcast, "Gunbound"} # stream"game"
  #   started = {broadcast, "2011-03-19T15:42:22Z"} # stream"created_at"
  #   ended = {broadcast, Date.now}
  def filters(stream) do
    IO.inspect stream["created_at"]

    {:ok, created_at} = case DateFormat.parse(stream["created_at"], "{ISOz}") do
      {:ok, created_at} -> DateFormat.format(created_at, "{s-epoch}")
      {:error, message} -> Logger.error message
    end

    IO.inspect created_at

    {created_at, _} = Integer.parse(created_at)

    # created_at = DateFormat.format(created_at, "{s-epoch}")

    [{"language",   stream["channel"]["broadcaster_language"]},
     {"mature",     stream["channel"]["mature"]},
     {"fps",        stream["average_fps"]},
     {"height",     stream["height"]},
     {"game",       stream["game"]},
     {"channel",    stream["channel"]["name"]},
     {"started_at", created_at}]

  end

  # viewers = {stream, [{184729423947, 3283}, {184729423947, 3283}]} # "viewers"
  def metrics(stream) do
    viewers = stream["viewers"]

    [{"viewers", viewers}]
  end

  def capture(stream) do
    id      = id(stream)
    meta    = meta(stream)
    metrics = metrics(stream)
    filters = filters(stream)

    %{id: id, meta: meta, metrics: metrics, filters: filters}
  end

  def process(stream) do
    data = capture(stream)

    save(stream, data.id)

    mongo_data = generate_hash_set(data)
      |> convert_hash_set_to_map

    mongo_save(mongo_data, data.id)

    data
  end

  def process(set_key, stream) do
    data = process(stream)


    # add_to_set(set_key, data.id)
  end
end