defmodule TwitchDiscovery.Index.Broadcast do
  use TwitchDiscovery.Index.Base
  alias TwitchDiscovery.Index.Stream


  def db_key(index) do
    "broadcasts-" <> index_to_string(index)
  end

  def db_key() do
    "broadcasts-" <> Index.get_current_index()
  end

  def process(dataset) do

  end

  def data_length(dataset) do
    length(dataset["streams"])
  end

  def initial_url do
    "/streams?limit=100"
  end

  def collection_name() do
    TwitchDiscovery.Index.get_current_index()
    |> collection_name()
  end

  def collection_name(index) do
    "streams-" <> index
  end

  def parse_params_to_query(params) do
    Stream.parse_params_to_query(params)
  end


  def sorting(params) do
    Stream.sorting(params)
  end

  def map_result(result), do: Stream.map_result(result)
end