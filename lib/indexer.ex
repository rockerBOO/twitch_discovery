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

  def save(document, id) do
    IO.puts "Save me!"
    IO.inspect document
    IO.inspect id

    key = "process-broadcast-" <> Integer.to_string(id)

    IO.puts "KEY:"
    IO.inspect key

    redis = :redis_client |> Process.whereis()

    redis
      |> Exredis.query(["SET", key, Poison.encode!(document)])

    redis
      |> Exredis.query(["EXPIRE", key, 86400])
  end
end