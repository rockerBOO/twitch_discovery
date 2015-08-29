defmodule TwitchDiscovery.ChannelController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def channel(conn, %{"channel" => channel} = params) do
    channel_details = RestTwitch.Channels.get(channel)

    videos = RestTwitch.Channels.videos(channel, %{limit: 9}) |> Map.fetch!("videos")

    render conn, "channel.html", channel: channel_details, videos: videos
  end

  def lookup(conn, %{"channel" => channel} = params) do
    redirect conn, to: "/channel/" <> channel
  end

  def lookup(conn, params) do
    render conn, "lookup.html"
  end

  def lookup_channel(channel) do
    RestTwitch.Follows.channels(channel)
    |> Map.fetch!("follows")
  end
end
