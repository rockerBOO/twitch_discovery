# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :twitch_discovery, TwitchDiscovery.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "zN2grEQjPFFdYaiVuYU1bLTHrMOcchLsIBXPz9lP7UOMGyH0dXq0tZZNxQOdsw74",
  render_errors: [default_format: "html"],
  pubsub: [name: TwitchDiscovery.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :quantum, cron: [
  # Every minute
  "*/15 * * * *": &TwitchDiscovery.Index.index/0
  # "* */1 * * *": &TwitchDiscovery.Index.index_games/0
]