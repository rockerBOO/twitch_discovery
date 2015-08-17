defmodule TwitchDiscovery.StreamView do
  use TwitchDiscovery.Web, :view

  def render("streams_json.json", %{streams: streams}) do
    streams
  end
end
