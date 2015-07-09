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

  def videos_in_channel(conn, %{"channel" => channel}) do
    videos = RestTwitch.Videos.channel(channel)
      |> Enum.map(fn (video) ->
          length = video_length(video["length"])
          length_hours = length.hours
          length_minutes = length.minutes
          length_seconds = length.seconds

          Map.merge(video, %{
            "length_hours" => length_hours,
            "length_minutes" => length_minutes,
            "length_seconds" => length_seconds
          })
        end)

    IO.inspect videos

    render conn, "videos_in_channel.html", videos: videos
  end

  def top_videos_on_twitch(conn, params) do
    games = get_games(20)

    videos = RestTwitch.Videos.top(params, %{ttl: 3600})
      |> Enum.map(fn (video) ->
          length = video_length(video["length"])
          length_hours = length.hours
          length_minutes = length.minutes
          length_seconds = length.seconds

          Map.merge(video, %{
            "length_hours" => length_hours,
            "length_minutes" => length_minutes,
            "length_seconds" => length_seconds
          })
        end)

    IO.inspect videos

    render conn, "top_videos_on_twitch.html", videos: videos, games: games
  end

  def videos_following(conn, params) do
    # games = get_games(20)

    token = get_session(conn, :access_token)
    defaults = %{"limit" => 24}

    videos = RestTwitch.Users.videos(token.access_token, Map.merge(defaults, params))

    render conn, "following.html", videos: videos
  end

  def get_games(limit \\ 10) do
    RestTwitch.Games.top(%{"limit" => limit}, Process.whereis(:redis_client))
  end
end