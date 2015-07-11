defmodule TwitchDiscovery.Indexer do
  def map_captured(captured, watch) do
    # Assemble new values based on modification watching
    Enum.map(watch, fn (field) ->
      case captured[field] do
        nil -> nil
        value -> Map.put(%{}, field, value)
      end
    end)
    # Remove false responses...
    |> Enum.filter(fn (x) -> x end)
    # Reduce list of maps to single map
    |> reduce()
  end

  def reduce([]) do
    []
  end

  def reduce(value) do
    value |> Enum.reduce(fn (value, acc) -> Map.merge(acc, value) end)
  end
end