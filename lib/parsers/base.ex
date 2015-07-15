defmodule TwitchDiscovery.Parser.Base do
  defmacro __using__(_) do
    quote do
      require Logger

      def redis_client() do
        :redis_client
          |> Process.whereis()
      end

      def redis_get(key) do
        redis_client()
          |> Exredis.query(["GET", key])
      end

      def get_current_index(), do: TwitchDiscovery.Index.get_current_index()
      def get_processing_index(), do: TwitchDiscovery.Index.get_processing_index()

      # HashSet for captured fields
      def generate_mongo_document(captured_fields) do
        # Process captured filters
        fields_reduce(%{}, captured_fields.filters)
        |> fields_reduce(captured_fields.meta)
        |> fields_reduce(captured_fields.metrics)
      end

      def fields_reduce(acc, fields) do
        acc |> reduce_to_map(fields)
      end

      def reduce_to_map(modified, dataset) do
        dataset
        |> Enum.reduce(modified, fn ({key, value}, modified) ->
          Map.put(modified, String.to_atom(key), value)
        end)
      end

      def save(data, id) do
        :redis_client
        |> Process.whereis()
        |> Exredis.query(["SETEX", db_key(id), 3600, Poison.encode!(data)])
      end

      def mongo_save(data, id) do
        IO.inspect data

        try do
          case Mongo.insert_one(MongoPool, get_processing_index() |> db_key(), data) do
            {:ok, _} -> :ok
            {:error, error} -> Logger.error error
          end
        rescue
          e in Mongo.Error -> e
        end
      end

      def process(document) do
        data = capture(document)

        save(document, data.id)

        generate_mongo_document(data)
          |> mongo_save(data.id)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end