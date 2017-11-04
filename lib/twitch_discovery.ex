defmodule TwitchDiscovery do
  use Application

  defmodule RedisError do
    defexception [:message, :response]
  end

  defmodule MongoError do
    defexception [:message, :response]
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    redis_client = case Exredis.start_link() do
      {:ok, redis_client} -> redis_client
      {:error, error} -> raise %RedisError{response: error, message: "Couldn't connect to Redis"}
    end

    Process.register(redis_client, :redis_client)

    {:ok, _} = Mongo.start_link(database: "twitch_discovery_dev")

    # {:ok, twitch_cache} =  RestTwitch.Cache.start_link(redis_client)

    children = [
      supervisor(TwitchDiscovery.Endpoint, []),

      worker(TwitchDiscovery.Repo, []),
      worker(RestTwitch.Cache, [redis_client]),
    ]

    opts = [strategy: :one_for_one, name: TwitchDiscovery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def quantum() do

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitchDiscovery.Endpoint.config_change(changed, removed)
    :ok
  end
end
