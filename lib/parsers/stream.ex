defmodule TwitchDiscovery.Parser.Stream do
  use TwitchDiscovery.Parser.Base
  require Logger
  use Timex

  def db_key(id), do: TwitchDiscovery.Index.Stream.db_key(id)
  def db_key(), do: TwitchDiscovery.Index.Stream.db_key()


  def id(stream) do
    stream["_id"]
  end

  def meta(stream) do
    [{"id", id(stream)},
     {"title", stream["title"]}]
  end

  def filters(stream) do
    {:ok, created_at} = case Timex.parse(stream["created_at"], "{ISO:Extended:Z}") do
      {:ok, created_at} -> Timex.format(created_at, "{s-epoch}")
      {:error, message} -> Logger.error message
    end

    {created_at, _} = Integer.parse(created_at)

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