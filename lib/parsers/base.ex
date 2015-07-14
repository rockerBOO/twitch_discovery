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

      def convert_hash_set_to_map(hash_set) do
        hash_set
          |> Enum.reduce(%{}, fn ({key, value}, acc) ->
            Map.merge(acc, Map.put(%{}, key, value))
          end)
      end

      # HashSet for captured fields
      def generate_hash_set(captured_fields) do
        broadcast_id = captured_fields.id
        modified     = HashSet.new

        # Process captured filters
        # [{"language", stream["channel"]["broadcaster_language"]},..]
        modified = captured_fields.filters
          |> Enum.reduce(modified, fn ({key, value}, modified) ->
            HashSet.put(modified, {String.to_atom(key), value})
          end)

        # Pass in previous modified and apply meta data
        modified = captured_fields.meta
          |> Enum.reduce(modified, fn ({key, value}, modified) ->
            HashSet.put(modified, {String.to_atom(key), value})
          end)

        captured_fields.metrics
          |> Enum.reduce(modified, fn ({key, value}, modified) ->
            HashSet.put(modified, {String.to_atom(key), value})
          end)
      end


      def save(data, id) do
        key   = db_key(id)
        redis = :redis_client |> Process.whereis()

        # Logger.debug "Sending json data to #{key} on Redis"

        redis |> Exredis.query(["SETEX", key, 3600, Poison.encode!(data)])
      end

      def mongo_save(data, id) do
        index = get_processing_index()
        # IO.inspect data

        collection = db_key(index)

        # Logger.debug "Saving to #{collection}"

        try do
          case Mongo.insert_one(MongoPool, collection, data) do
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

        generate_hash_set(data)
          |> convert_hash_set_to_map
          |> mongo_save(data.id)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

end