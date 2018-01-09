defmodule TwitchDiscovery.PageController do
  use TwitchDiscovery.Web, :controller
  use Timex
  alias OAuth2.Twitch
  alias TwitchDiscovery.Index.Stream

  def index(conn, _params) do
    # date_now = Timex.now
    # datetime = date_now |> Timex.shift(minutes: 5)
    # {:ok, min_uptime} = Timex.format(datetime, "{s-epoch}")
    # {min_uptime, _} = Integer.parse(min_uptime)

    streams = %{"viewers" => %{"$lt" => 100}} 
      |> Stream.find(limit: 20)

    #%{"viewers" => %{"$lt" => 100}, "started_at" => %{"$lt" => min_uptime}}

    # streams = Mongo.find(:mongo, "streams-2", %{"viewers" => %{"$lt" => 100}, "started_at" => %{"$lt" => min_uptime}}, [limit: 3, pool: DBConnection.Poolboy]) 
      # |> Enum.to_list()
      # |> TwitchDiscovery.Index.Stream.filter_results()

    IO.inspect streams

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
