defmodule TwitchDiscovery.Repo do
  use Ecto.Repo, otp_app: :twitch_discovery, adapter: Mongo.Ecto
end
