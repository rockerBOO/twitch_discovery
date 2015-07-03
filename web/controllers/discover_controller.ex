defmodule TwitchDiscovery.DiscoverController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do

    render conn, "index.html"
  end

 # %{"_id" => "v6693764",
 #   "_links" => %{"channel" => "https://api.twitch.tv/kraken/channels/riotgamesturkish",
 #     "self" => "https://api.twitch.tv/kraken/videos/v6693764"},
 #   "broadcast_id" => 15061507552, "broadcast_type" => "highlight",
 #   "channel" => %{"display_name" => "RiotGamesTurkish",
 #     "name" => "riotgamesturkish"},
 #   "description" => "Yaz Mevsimi - 5. Hafta 2. Gün - HWA vs OHM",
 #   "fps" => %{"audio_only" => 0.0, "chunked" => 49.9964507743083,
 #     "high" => 29.9913925833377, "low" => 29.9913925833377,
 #     "medium" => 29.9913925833377, "mobile" => 19.9942798675508}, "game" => nil,
 #   "length" => 3164,
 #   "preview" => "http://static-cdn.jtvnw.net/v1/AUTH_system/vods_6221/riotgamesturkish_15061507552_263497666/thumb/thumb0-320x240.jpg",
 #   "recorded_at" => "2015-06-28T14:25:10Z",
 #   "resolutions" => %{"chunked" => "1280x720", "high" => "1280x720",
 #     "low" => "640x360", "medium" => "852x480", "mobile" => "400x226"},
 #   "status" => "recorded", "tag_list" => "",
 #   "title" => "Yaz Mevsimi - 5. Hafta 2. Gün - HWA vs OHM",
 #   "url" => "http://www.twitch.tv/riotgamesturkish/v/6693764", "views" => 6203}
  def video_length(length) do
    hours = length / 3600
    remainder = length - hours * 3600
    minutes = remainder / 60
    seconds = remainder - minutes * 60

    int_hours = round hours
    int_minutes = round minutes
    int_seconds = round seconds

    %{hours: int_hours, minutes: int_minutes, seconds: int_seconds}
  end

  def top_videos_on_twitch(conn, params) do

    IO.inspect params

    videos = RestTwitch.Videos.top(params)
      |> Enum.map(fn (video) ->
          length = video_length(video["length"])

          IO.inspect length

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

    render conn, "top_videos_on_twitch.html", videos: videos
  end
end