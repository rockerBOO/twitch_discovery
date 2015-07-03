defmodule TwitchDiscovery.Router do
  use TwitchDiscovery.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwitchDiscovery do
    pipe_through :browser # Use the default browser stack


    resources "/videos", VideoController

    get "/", PageController, :index

    get "/streams/summary", StreamController, :summary
    get "/streams", StreamController, :index

    get "/search", SearchController, :index
    get "/search/streams", SearchController, :streams

    get "/discover/channel/:channel", DiscoverController, :videos_in_channel
    get "/discover", DiscoverController, :index
    get "/discover/videos/top", DiscoverController, :top_videos_on_twitch
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitchDiscovery do
  #   pipe_through :api
  # end
end
