# TwitchDiscovery.Index.index

defmodule TwitchDiscovery.Index.Base do
  defmacro __using__(_) do
    quote do
      use Timex
      require Logger

      def index_to_string(index) when is_integer(index) do
        Integer.to_string(index)
      end
      def index_to_string(index) do
        index
      end

      def get_next(dataset) do
        dataset
        |> process()

        if more?(dataset) do
          Logger.debug "MORE " <> dataset["_links"]["next"]
          request(dataset["_links"]["next"])
          |> get_next()
        else
          :ok
        end
      end

      def more?(dataset) do
        data_length(dataset) != 0
      end

      def request() do
        initial_url()
        |> request()
      end

      def request(url) do
        IO.inspect "Request! " <> url

        results = RestTwitch.Request.get_body!(url)
        |> Poison.decode!()

        results
      end

      def find(query, opts \\ []) do
        Mongo.find(MongoPool, collection_name(), query, opts)
        |> Enum.to_list
        |> Enum.map(&map_result(&1))
        |> Enum.reject(fn (result) ->
          nil == result
        end)
      end

      def format_query(query, orderby \\ %{}) do
        %{"$query" => query, "$orderby" => orderby}
      end

      def params_to_query(params) do
        parse_params_to_query(params)
        |> format_query(sorting(params))
      end
    end
  end
end