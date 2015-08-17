defmodule TwitchDiscovery.ChannelController do
  use TwitchDiscovery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def channel(conn, %{"channel" => channel} = params) do
    channel = RestTwitch.Channels.get(channel)

    render conn, "channel.html", channel: channel
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
