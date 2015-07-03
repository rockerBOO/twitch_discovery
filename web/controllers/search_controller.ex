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
    games = RestTwitch.Games.top()
    streams = RestTwitch.Search.streams(params)
      |> Enum.map(fn (stream) ->
        stream
        end)

    IO.inspect streams

    render conn, "streams.html", streams: streams, games: games
  end

  def streams(conn, _params) do
    redirect conn, to: "/search"
  end


  def index(conn, _params) do
    render conn, "index.html"
  end
end