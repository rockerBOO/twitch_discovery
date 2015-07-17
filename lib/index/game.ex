defmodule TwitchDiscovery.Index.Game do
	alias TwitchDiscovery.Parser.Game
  use TwitchDiscovery.Index.Base

  def db_key(index) do
    IO.inspect index
    "games-" <> index_to_string(index)
  end

  def db_key() do
    "games-" <> Index.get_current_index()
  end

  def process(%{"top" => []}), do: finish_indexing()
  def process(resultset) when is_map(resultset) do
    resultset
    |> Map.fetch!("top")
    |> parse_filters()
    |> save_to_mongo()

    request(resultset["_links"]["next"])
    |> process()
  end

  def finish_indexing() do
    Logger.info "Finished indexing games"

    Mongo.delete_many(
      MongoPool,
      Index.get_current_index() |> collection_name(),
      %{}
    )
  end

  def parse_filters(games) do
    games
    |> Enum.map(fn (game) ->
      Game.process(game)
    end)
  end

  def data_length(dataset) do
    length(dataset["top"])
  end

  def initial_url do
    "/games/top?limit=100"
  end

  def collection_name() do
    TwitchDiscovery.Index.get_current_index()
    |> collection_name()
  end

  def collection_name(index) do
    "games-" <> index
  end

  def redis_save_many(results) do

  end

  def parse_params_to_query(_params) do
    %{}
  end

  def sorting(params) do
    %{}
  end

  def map_result(result), do: result
end