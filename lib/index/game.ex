defmodule TwitchDiscovery.Index.Game do
	alias TwitchDiscovery.Parser.Game
  alias TwitchDiscovery.Index

  def db_key(index) do
    "games"
  end

  def db_key() do
    "games-" <> Index.get_current_index()
  end

  def process(games) do
    games
    |> Enum.each(fn (game) ->
      spawn(fn ->
        Game.process(game)
      end)
    end)
  end
end