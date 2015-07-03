defmodule TwitchDiscovery.DiscoverController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf

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

  def streams(conn, params) do
    games = get_games(10)

    streams = "/streams?%s"
      |> sprintf([URI.encode_query(params)])
      |> RestTwitch.Request.get!()
      |> Map.fetch!(:body)
      |> Poison.decode!()
      |> Map.fetch!("streams")
      |> Enum.map(fn (stream) ->
          %{
            "game" => stream["game"],
            "id" => stream["_id"],
            "viewers" => stream["viewers"],
            "channel_url" => stream["channel"]["url"],
            "thumbnail" => stream["preview"]["medium"],
            "created_at" => stream["created_at"],
            "average_fps" => stream["average_fps"],
            "video_height" => stream["video_height"],
            "channel_name" => stream["channel"]["name"],
            "channel_mature" => stream["channel"]["mature"]
          }
        end)

    render conn, "streams.html", streams: streams, games: games
  end

  def videos_in_channel(conn, %{"channel" => channel}) do
    videos = RestTwitch.Videos.channel(channel)
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
    render conn, "videos_in_channel.html", videos: videos
  end

  def top_videos_on_twitch(conn, params) do
    games = get_games(100)

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

  def get_games(limit \\ 10) do
    RestTwitch.Games.top(%{"limit" => limit})
  end
end