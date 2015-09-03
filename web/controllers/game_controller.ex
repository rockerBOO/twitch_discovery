defmodule TwitchDiscovery.GameController do
  use    TwitchDiscovery.Web, :controller
  import ExPrintf
  alias  TwitchDiscovery.Index.Game

  def cache do
    redis = :redis_client |> Process.whereis()
    key   = "games-list"

    redis |> Exredis.query(["GET", key])
  end

  def find_games(game, games \\ [], offset \\ 0) do
    found_games = Game.find(%{"game.name" => %BSON.Regex{pattern: game, options: "i"}}, [
      limit: 2000,
      sort: %{"game.name" => -1},
      skip: offset,
      projection: %{"game.name" => 1}
    ])

    if length(found_games) > 0 do
      find_games(game, Enum.into(games, found_games), offset + 2000)
    else
      games
    end
  end

  def autocomplete(conn, params) do
    IO.inspect "/#{params["query"]}/i"

    suggestions = find_games("#{params["query"]}")
    |> Enum.map(fn (match) ->
      %{"value" => match["game"]["name"], "data" => match["game"]["name"]}
    end)

    IO.inspect suggestions

    json conn, %{suggestions: suggestions}
 	end
end
