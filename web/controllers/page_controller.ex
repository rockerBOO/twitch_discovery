defmodule TwitchDiscovery.PageController do
  use TwitchDiscovery.Web, :controller
  alias OAuth2.Twitch

  def index(conn, _params) do
    render conn, "index.html"
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
