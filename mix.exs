defmodule TwitchDiscovery.Mixfile do
  use Mix.Project

  def project do
    [app: :twitch_discovery,
     version: "0.0.2",
     elixir: "~> 1.4",
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
                    :logger, :phoenix_ecto, :mongodb_ecto, :ecto,
                    :quantum, :httpoison, :gettext,
                    :exredis, :mongodb, :tzdata]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:mongodb_ecto, github: "michalmuskala/mongodb_ecto", branch: "ecto-2"},
     {:phoenix_ecto, "~> 3.0.1"},
     # {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:exredis, ">= 0.1.1"},
     {:number, "~> 0.3.4"},
     {:quantum, ">= 1.2.4"},
     {:gettext, "~> 0.9"},
     {:exprintf, "~> 0.1", override: true},
     # {:rest_twitch, github: "rockerBOO/rest_twitch"},
     {:rest_twitch, path: "../rest_twitch"},
     {:httpoison, "~> 0.10.0"},
     {:timex, "~> 3.0"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:exrm, "~> 0.15.3", only: :dev},
     {:exprof, ">= 0.2.0", only: :dev},
     # {:beaker, ">= 0.0.3"},
     {:cowboy, "~> 1.0"}]
  end
end
