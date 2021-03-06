defmodule TwitchDiscovery.Mixfile do
  use Mix.Project

  def project do
    [app: :twitch_discovery,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {TwitchDiscovery, []},
     applications: [:phoenix, :phoenix_html, :cowboy,
                    :logger, :phoenix_ecto, 
                    :quantum, :httpoison,
                    :exredis, :mongodb, :tzdata]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:plug, "~>1.3.5", override: true},
     {:phoenix_ecto, "~> 3.3"},
     {:postgrex, "~> 0.13"},
     {:phoenix_html, "~> 2.6"},
     {:exredis, ">= 0.1.1"},
     {:number, "~> 0.3.4"},
     {:quantum, ">= 2.2.1"},
     {:exprintf, "~> 0.1", override: true},
     {:mongodb, "~> 0.4.3"},
     {:rest_twitch, github: "rockerBOO/rest_twitch"},
     {:httpoison, "~> 0.13"},
     {:timex, "~> 3.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:exrm, "~> 0.15.3", only: :dev},
     {:exprof, ">= 0.2.0", only: :dev},
     {:cowboy, "~> 1.0"}]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
