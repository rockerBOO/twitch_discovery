defmodule TwitchDiscovery.Index.Game do
	alias TwitchDiscovery.Parser.Game
  use TwitchDiscovery.Index.Base

  @name "games"

  def db_key(index) do
    db_key(@name, index)
  end

  def db_key() do
    db_key(@name)
  end

  def collection_name(index),
  do: collection_name(@name, index)

  def get_current_index do
    get_current_index(@name)
  end

  def get_processing_index, do: get_processing_index(@name)
  def set_index(index), do: set_index(@name, index)

  # def db_key(index) do
  #   "games-" <> index_to_string(index)
  # end

  # def db_key() do
  #   "games-" <> get_current_index()
  # end

  # def get_current_index, do: get_current_index("game")
  # def get_processing_index, do: get_processing_index("game")
  # def set_index(index), do: set_index("game", index)

  def process(%{"top" => []}), do: finish_indexing
  def process(resultset) when is_map(resultset) do
    resultset
    |> Map.fetch!("top")
    |> parse_filters()
    |> save_to_mongo()

    request(resultset["_links"]["next"])
    |> process()
  end

  def parse_filters(games) do
    games
    |> Enum.map(fn (game) ->
      Game.process(game)
    end)
  end

  def data_length(dataset),
  do: length(dataset["top"])

  def initial_url,
  do: "/games/top?limit=100"

  # def collection_name(),
  #   do: get_current_index() |> collection_name()

  # def collection_name(index),
  #   do: "#{@name}-#{index}"

  def map_result(result),
  do: result

  def redis_save_many(results) do

  end

  def parse_params_to_query(_params), do: %{}

  def sorting(params),
  do: %{}

  def map_result(result),
  do: result
end