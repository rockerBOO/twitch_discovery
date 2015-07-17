defmodule TwitchDiscovery.Index.Broadcast do
  use TwitchDiscovery.Index.Base
  alias TwitchDiscovery.Index.Stream
  alias TwitchDiscovery.Index

  def db_key(index) do
    "broadcasts-" <> index_to_string(index)
  end

  def db_key() do
    "broadcasts-" <> Index.get_current_index()
  end

  def parse_filters(dataset) do
    dataset
    |> Map.fetch!("streams")
    |> Enum.map(fn (stream) ->
      Stream.process(stream)
    end)
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