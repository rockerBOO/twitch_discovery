defmodule TwitchDiscovery.PageController do
  use TwitchDiscovery.Web, :controller
  use Timex
  alias OAuth2.Twitch
  alias TwitchDiscovery.Index.Stream

  def index(conn, _params) do
    date_now = Timex.now
    datetime = date_now |> Timex.shift(minutes: 5)
    {:ok, min_uptime} = Timex.format(datetime, "{s-epoch}")
    {min_uptime, _} = Integer.parse(min_uptime)

    streams = %{"viewers" => %{"$lt" => 100}, "started_at" => %{"$lt" => min_uptime}}
    |> Stream.find(limit: 3)

    render conn, "index.html", streams: streams
  end

  def about(conn, _params) do
    render conn, "about.html"
  end

  def privacy(conn, _params) do
    render conn, "privacy_policy.html"
  end

  def terms(conn, _params) do
    render conn, "terms_of_use.html"
  end

  def auth(conn, _params) do
    Twitch.authorize_url!
  end
end
