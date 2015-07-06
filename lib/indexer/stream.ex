defmodule TwitchDiscovery.Indexer.Stream do

  # # Broadcast
  # ## Meta
  #   broadcast_id = {broadcast, stream["_id"]}
  #   titles = {channel, ["4v1 4HP Clutch", "Minecon 2015 - Main Stream"]}

  # ## Filters
  #   channel = {broadcast, "rockerboo"}
  #   game = {broadcast, "Gunbound"} # stream"game"
  #     started = {broadcast, "2011-03-19T15:42:22Z"} # stream"created_at"
  #   ended = {broadcast, Date.now}
  def meta(stream) do
    stream_id = stream["_id"]

    %{
      "stream_id" => stream_id
    }
  end

  def filters(stream) do
    language    = stream["channel"]["broadcaster_language"]
    mature      = stream["channel"]["mature"]
    fps         = stream["average_fps"]
    height      = stream["height"]
    game        = stream["game"]
    created_at  = stream["created_at"]

    %{
      "language"    => language,
      "mature"      => mature,
      "fps"         => fps,
      "height"      => height,
      "game"        => game,
      "created_at"  => created_at
    }
  end

  # viewers = {stream, [{184729423947, 3283}, {184729423947, 3283}]} # "viewers"
  def metrics(stream) do
    viewers = stream["viewers"]

    metrics = {Timex.Date.now, viewers}

    %{
      "metrics" => metrics
    }
  end

  def capture(stream) do
    filters = filters(stream)
    metrics = metrics(stream)
    meta    = meta(stream)

    # IO.inspect broadcast

    %{meta: meta, metrics: metrics, filters: filters}
  end

  def process(stream) do
    capture(stream)
      # |> save_modified()

    broadcast =  TwitchDiscovery.Indexer.Broadcast.process(stream)

  end
end