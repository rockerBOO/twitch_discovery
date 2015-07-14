defmodule TwitchDiscovery.Index.Stream do
	use TwitchDiscovery.Index.Base
  alias TwitchDiscovery.Parser.Stream
  alias TwitchDiscovery.Parser.Broadcast

  def process(dataset) do
    dataset
    |> Map.fetch!("streams")
    |> Enum.each(fn (stream) ->
      spawn(fn ->
        Stream.process(stream)
        Broadcast.process(stream)
      end)
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
end