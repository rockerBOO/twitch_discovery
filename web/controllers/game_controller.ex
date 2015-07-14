defmodule TwitchDiscovery.GameController do
  use TwitchDiscovery.Web, :controller
  import ExPrintf

  def cache do
    redis = :redis_client |> Process.whereis()
    key   = "games-list"

    redis |> Exredis.query(["GET", key])
  end

  def autocomplete(conn, params) do
    games = cache()

    if games == :undefined do
      games = []
    else
      games = Poison.decode!(games)
    end

    suggestions = Enum.filter(games, fn(game) ->
       game =~ params["query"]
    end)
    |> Enum.map(fn (match) ->
      %{value: match, data: match}
    end)

    json conn, %{suggestions: suggestions}
 	end
end
