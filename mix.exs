defmodule TwitchDiscovery.Mixfile do
  use Mix.Project

  def project do
    [app: :twitch_discovery,
     version: "0.0.6",
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
      applications: [
        :phoenix, :phoenix_html, :cowboy,
        :logger, :phoenix_ecto, :postgrex,
        :quantum, :httpoison, :exprintf, :number,
        :exredis, :mongodb, :tzdata,
        :rest_twitch, :timex
      ]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
      {:phoenix, "~> 1.3"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:exredis, ">= 0.2.4"},
      {:number, "~> 0.3.4"},
      {:quantum, ">= 2.2.1"},
      {:exprintf, "~> 0.1", override: true},
      {:mongodb, "~> 0.4.3"},
      {:rest_twitch, github: "rockerBOO/rest_twitch"},
      # {:rest_twitch, path: "/home/rockerboo/projects/rest_twitch"},
      {:httpoison, "~> 0.7"},
      {:timex, "~> 3.1"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:exrm, "~> 0.15.3", only: :dev},
      {:exprof, ">= 0.2.0", only: :dev},
      {:distillery, "~> 1.5", runtime: false},
      # {:beaker, ">= 0.0.3"},
      {:cowboy, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
