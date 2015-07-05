defmodule TwitchDiscovery.Indexer.Broadcast do

  # # Broadcast

  def is_modified?(stream) do

  end

  def save_modified(captured, watch) do
    # IO.puts "captured"
    # IO.inspect captured
    # IO.inspect watched

    # metric_save({"title", stream["channel"]["status"]})

    map_captured(captured.meta, watch)
      |> save(captured.meta["broadcast_id"])

    map_captured(captured.filters, watch)
      |> save(captured.meta["broadcast_id"])
  end

  def map_captured(captured, watch) do
    # Assemble new values based on modification watching
    Enum.map(watch, fn (field) ->
      case captured[field] do
        nil -> nil
        value -> Map.put(%{}, field, value)
      end
    end)
    # Remove false responses...
    |> Enum.filter(fn (x) -> x end)
    # Reduce list of maps to single map
    |> reduce()
  end

  def reduce([]) do
    []
  end

  def reduce(value) do
    value |> Enum.reduce(fn (value, acc) -> Map.merge(acc, value) end)
  end

  def save(document, id) do
    IO.puts "Save me!"
    IO.inspect document

    # IO.inspect mongo_get(mongo_conn, id)

    # case mongo_get(mongo_conn, id) do
    #   %Mongo.Cursor{_} -> mongo_update(mongo_conn, id, document)
    #   _ -> raise %Elirc.Error{reason: "Mongo get WTF"}
    # end
  end

  def mongo_get(mongo_conn, id) do
    mongo_conn
      |> Mongo.db("twitch_discovery_dev")
      |> Mongo.Db.collection("broadcast")
      |> Mongo.Collection.find(%{"broadcast_id" => id})
      |> Mongo.Find.exec()
      |> Mongo.Cursor.exec("broadcast")
  end

  # ## Meta
  #   broadcast_id = {broadcast, stream["_id"]}
  #   titles = {channel, ["4v1 4HP Clutch", "Minecon 2015 - Main Stream"]}

  def meta(stream) do
    broadcast_id = stream["_id"]
    title        = stream["title"]

    %{
      "broadcast_id" => broadcast_id,
      "title"        => title
    }
  end

  # ## Filters
  #   channel = {broadcast, "rockerboo"}
  #   game = {broadcast, "Gunbound"} # stream"game"
  #   started = {broadcast, "2011-03-19T15:42:22Z"} # stream"created_at"
  #   ended = {broadcast, Date.now}
  def filters(stream) do
    language  = stream["channel"]["broadcaster_language"]
    channel   = stream["channel"]["name"]
    mature    = stream["channel"]["mature"]
    fps       = stream["average_fps"]
    height    = stream["height"]
    game      = stream["game"]
    started   = stream["created_at"]

    %{
      "language"  => language,
      "mature"    => mature,
      "fps"       => fps,
      "height"    => height,
      "game"      => game,
      "channel"   => channel,
      "started"   => started
    }
  end

  # viewers = {stream, [{184729423947, 3283}, {184729423947, 3283}]} # "viewers"
  def metrics(stream) do
    viewers = stream["viewers"]

    %{
      "viewers" => viewers
    }
  end

  def capture(stream) do
    meta    = meta(stream)
    metrics = metrics(stream)
    filters = filters(stream)

    %{meta: meta, metrics: metrics, filters: filters}
  end


  def process(stream) do
    capture(stream)
      |> save_modified([
        "game", "channel", "title", "language",
        "mature", "fps", "height", "game"])
  end
end