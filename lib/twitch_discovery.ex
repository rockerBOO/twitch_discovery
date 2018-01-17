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
      {:error, error} -> raise %RedisError{response: error, message: error}
    end

    Process.register(redis_client, :redis_client)

    children = [
      supervisor(TwitchDiscovery.Endpoint, []),
      worker(Mongo, [[name: :mongo, hostname: "mongo", database: "discovery", pool: DBConnection.Poolboy]]),
      # worker(TwitchDiscovery.Repo, []),
      worker(TwitchDiscovery.Scheduler, []),
      worker(RestTwitch.Cache, [redis_client]),
    ]

    opts = [strategy: :one_for_one, name: TwitchDiscovery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitchDiscovery.Endpoint.config_change(changed, removed)
    :ok
  end
end
