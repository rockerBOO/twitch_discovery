defmodule TwitchDiscovery.Index.Broadcast do
  use TwitchDiscovery.Index.Base
  alias TwitchDiscovery.Index.Stream
  alias TwitchDiscovery.Index

  @name "broadcasts"

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

  def parse_filters(dataset) do
    dataset
    |> Map.fetch!("streams")
    |> Enum.map(fn (stream) ->
      Stream.process(stream)
    end)
  end

  def data_length(dataset),
    do: length(dataset["streams"])

  def initial_url,
    do: "/streams?limit=100"

  def collection_name,
    do: get_current_index() |> collection_name()

  def collection_name(index),
    do: "streams-" <> index

  def parse_params_to_query(params),
    do: Stream.parse_params_to_query(params)

  def sorting(params),
    do: Stream.sorting(params)

  def map_result(result),
    do: Stream.map_result(result)
end