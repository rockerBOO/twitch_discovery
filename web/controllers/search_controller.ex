defmodule TwitchDiscovery.SearchController do
  use TwitchDiscovery.Web, :controller

  defmodule Stream do
    defstruct [
      :game,
      :viewers,
      :title,
      :video_height,
      :average_fps,
      :channel,
      :thumbnail]
  end

  def streams(conn, %{"q" => query} = params) do
    games = RestTwitch.Games.top(%{"limit" => 20})
    streams = RestTwitch.Search.streams(params)
    |> Enum.map(fn (stream) ->
      for %{"channel" => channel} <- stream do
        case channel["url"] do
          status -> status
          nil -> Map.put(channel, "url", "http://www.twitch.tv/" <> channel["name"])
        end
      end

      stream
    end)

    render conn, "streams.html", search: query, streams: streams, games: games
  end

  def streams(conn, _params) do
    redirect conn, to: "/search"
  end


  def index(conn, _params) do
    render conn, "index.html"
  end
end
