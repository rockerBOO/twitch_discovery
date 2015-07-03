defmodule TwitchDiscovery.DiscoverController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do

    render conn, "index.html"
  end

  def video_length(length) do
    hours = Float.floor(length / 3600)
    remainder = length - hours * 3600
    minutes = Float.floor(remainder / 60)
    seconds = Float.floor(remainder - minutes * 60)

    int_hours = round hours
    int_minutes = round minutes
    int_seconds = round seconds

    %{length: length, hours: int_hours, minutes: int_minutes, seconds: int_seconds}
  end

  def top_videos_on_twitch(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 100})

    videos = RestTwitch.Videos.top(params)
      |> Enum.map(fn (video) ->
          length = video_length(video["length"])
          length_hours = length.hours
          length_minutes = length.minutes
          length_seconds = length.seconds

          %{
            "id" => video["_id"],
            "length_hours" => length_hours,
            "length_minutes" => length_minutes,
            "length_seconds" => length_seconds,
            "thumbnail" => video["preview"],
            "title" => video["title"],
            "url" => video["url"],
            "views" => video["views"]
          }
        end)

    render conn, "top_videos_on_twitch.html", videos: videos, games: games
  end
end