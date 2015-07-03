defmodule TwitchDiscovery.StreamController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf

  def index(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20})

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

  def summary(conn, params) do
    games = RestTwitch.Games.top(%{"limit" => 20})

    summary = "/streams/summary?%s"
      |> sprintf([URI.encode_query(params)])
      |> RestTwitch.Request.get!()
      |> Map.fetch!(:body)
      |> Poison.decode!()

    IO.inspect summary

    render conn, "summary.html",
      games: games,
      viewers: summary["viewers"],
      channels: summary["channels"]
  end
end
