defmodule TwitchDiscovery.Parser.Broadcast do
  use TwitchDiscovery.Parser.Base
  use Timex
  require Logger

  def db_key(id) do
    "broadcasts-" <> Integer.to_string(id)
  end

  def db_key(id, field) do
    "broadcasts-" <> Integer.to_string(id) <> "-" <> field
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
    {:ok, created_at} = case DateFormat.parse(stream["created_at"], "{ISOz}") do
      {:ok, created_at} -> DateFormat.format(created_at, "{s-epoch}")
      {:error, message} -> Logger.error message
    end

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
end