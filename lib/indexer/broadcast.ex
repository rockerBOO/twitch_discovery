defmodule TwitchDiscovery.Indexer.Broadcast do
  alias TwitchDiscovery.Indexer

  def is_modified?(stream) do

  end

  def save_modified(captured, watch) do
    # IO.puts "captured"
    # IO.inspect captured
    # IO.inspect watched

    # metric_save({"title", stream["channel"]["status"]})

    Indexer.map_captured(captured.meta, watch)
      |> Indexer.save(captured.meta["broadcast_id"])

    Indexer.map_captured(captured.filters, watch)
      |> Indexer.save(captured.meta["broadcast_id"])
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
        "mature", "fps", "height"])
  end
end