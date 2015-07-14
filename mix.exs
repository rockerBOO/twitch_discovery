defmodule TwitchDiscovery.Mixfile do
  use Mix.Project

  def project do
    [app: :twitch_discovery,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {TwitchDiscovery, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :quantum, :httpoison, :exredis, :mongodb]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.14"},
     {:phoenix_ecto, "~> 0.5"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 1.1"},
     {:exredis, ">= 0.1.1"},
     {:number, "~> 0.3.4"},
     {:quantum, ">= 1.2.4"},
     {:mongodb, github: "ericmj/mongodb"},
     # {:rest_twitch, github: "rockerBOO/rest_twitch"},
     {:rest_twitch, path: "/home/rockerboo/projects/rest_twitch"},
     {:httpoison, "~> 0.7"},
     {:timex, "~> 0.16.1"},
     {:phoenix_live_reload, "~> 0.4", only: :dev},
     {:exrm, "~> 0.15.3", only: :dev},
     {:cowboy, "~> 1.0"}]
  end
end
