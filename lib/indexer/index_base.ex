defmodule TwitchDiscovery.IndexBase do
  defmacro __using__(_) do
    quote do
      defp db_key(id) do
        "index-base-" <> Integer.to_string(id)
      end

      def save(document, id) do
        IO.puts "Save me!"
        IO.inspect document
        IO.inspect id

        key = db_key(id)

        IO.puts "KEY:"
        IO.inspect key

        redis = :redis_client |> Process.whereis()

        redis
          |> Exredis.query(["SET", key, Poison.encode!(document)])

        redis
          |> Exredis.query(["EXPIRE", key, 86400])
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

end