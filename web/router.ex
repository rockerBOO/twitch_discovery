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


    resources "/_videos", VideoController

    get "/user", UserController, :index

    get "/channel", ChannelController, :index

    get "/auth/twitch/callback", OAuthController, :callback
    get "/auth/twitch", OAuthController, :auth
    get "/auth/confirmation", OAuthController, :confirmation

    get "/follow/:channel", UserController, :follow
    get "/follows/:channel", UserController, :follows

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms

    get "/broadcasts", BroadcastController, :index

    get "/channels", ChannelController, :index
    get "/channel/:channel", ChannelController, :channel

    get "/games/autocomplete", GameController, :autocomplete

    get "/streams/summary", StreamController, :summary
    get "/streams/live", StreamController, :live_streams
    get "/streams", StreamController, :index
    get "/streams/following", StreamController, :following

    get "/search", SearchController, :index
    get "/search/streams", SearchController, :streams

    get "/discover/channel/:channel", DiscoverController, :videos_in_channel
    get "/discover", DiscoverController, :index
    get "/discover/videos/top", DiscoverController, :top_videos_on_twitch
    get "/videos/following", DiscoverController, :videos_following
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitchDiscovery do
  #   pipe_through :api
  # end
end
