defmodule TwitchDiscovery.Parser.Base do
  defmacro __using__(_) do
    quote do
      require Logger

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

      def process(document) do
        capture(document)
        |> generate_mongo_document()
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end