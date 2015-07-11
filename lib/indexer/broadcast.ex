defmodule TwitchDiscovery.Indexer.Broadcast do
  alias TwitchDiscovery.Indexer
  use TwitchDiscovery.IndexBase
  require Logger

  def db_key(id) do
    "tw-broadcast-" <> Integer.to_string(id)
  end

  def db_key(id, field) do
    "tw-broadcast-" <> Integer.to_string(id) <> "-" <> field
  end

  def find_modified(captured_fields, watch_fields) do
    broadcast_id = captured_fields.id


    Logger.debug "Find Modified " <> Integer.to_string(broadcast_id)
    IO.inspect captured_fields
    IO.inspect watch_fields

    Logger.debug "modified"
    modified = HashSet.new

    modified = captured_fields.filters
      |> Enum.reduce(modified, fn ({key, value}, modified) ->
        HashSet.put(modified, {key, value})
      end)
      |> IO.inspect

    modified = captured_fields.meta
      |> Enum.reduce(modified, fn ({key, value}, modified) ->
        HashSet.put(modified, {key, value})
      end)

    modified
      |> Enum.map(fn ({key, value}) ->
        process_modified(broadcast_id, {key, value})
      end)
      |> IO.inspect

  end


  def process_modified(id, {field, value}) do
    case is_field_modified?(id, field, value) do
      true -> save_field(id, field, value)
      false -> nil
    end
  end

  def process_modified(id, []) do
    :ok
  end

  def is_field_modified?(id, field, value) do
    redis = :redis_client |> Process.whereis()
    key   = db_key(id)

    cached_value = redis |> Exredis.query(["HGETALL", key])

    Logger.debug "is_field_modified?"
    IO.inspect cached_value

    case cached_value do
      :undefined -> true
      nil -> true
      cv -> IO.inspect cv; value == cv
    end
  end

  def save_field(id, field, value) when is_float(value) do
    save_field(id, field, round(value))
  end

  def save_field(id, field, value) do
    Logger.debug "Save Field --"
    Logger.debug Integer.to_string(id)
    Logger.debug "field: " <> field
    IO.inspect value

    redis = :redis_client |> Process.whereis()
    key   = db_key(id)

    Logger.debug "HSET" <> key <> " " <> field

    redis |> Exredis.query(["HSET", key, field, value])
    redis |> Exredis.query(["EXPIRE", key, 86400])
  end

  def save_modified(captured, watch) do
    # metric_save({"title", stream["channel"]["status"]})

    Indexer.map_captured(captured.meta, watch)
      # |> save(captured.meta["broadcast_id"])

    Indexer.map_captured(captured.filters, watch)
      # |> save(captured.meta["broadcast_id"])
  end

  # ## Meta
  #   broadcast_id = {broadcast, stream["_id"]}
  #   titles = {channel, ["4v1 4HP Clutch", "Minecon 2015 - Main Stream"]}

  def id(stream) do
    stream["_id"]
  end

  def meta(stream) do
    [{"title",        stream["title"]}]
  end

  # ## Filters
  #   channel = {broadcast, "rockerboo"}
  #   game = {broadcast, "Gunbound"} # stream"game"
  #   started = {broadcast, "2011-03-19T15:42:22Z"} # stream"created_at"
  #   ended = {broadcast, Date.now}
  def filters(stream) do
    [{"language", stream["channel"]["broadcaster_language"]},
     {"mature",   stream["channel"]["mature"]},
     {"fps",      stream["average_fps"]},
     {"height",   stream["height"]},
     {"game",     stream["game"]},
     {"channel",  stream["channel"]["name"]},
     {"started",  stream["created_at"]}]
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
    fields = ["game", "channel", "title", "language",
      "mature", "fps", "height"]

    capture(stream)
      |> find_modified(fields)
      # |> save()
  end
end