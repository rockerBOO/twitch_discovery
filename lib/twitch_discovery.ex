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

    {:ok, mongo_pool} = MongoPool.start_link(database: "discovery", size: 20, max_overflow: 5)

    # {:ok, twitch_cache} =  RestTwitch.Cache.start_link(redis_client)

    children = [
      # Start the endpoint when the application starts
      supervisor(TwitchDiscovery.Endpoint, []),
      # Start the Ecto repository
      worker(TwitchDiscovery.Repo, []),
      worker(RestTwitch.Cache, [redis_client]),
      # Here you could define other workers and supervisors as children
      # worker(TwitchDiscovery.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
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
