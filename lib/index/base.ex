# TwitchDiscovery.Index.index

defmodule TwitchDiscovery.Index.Base do
  defmacro __using__(_) do
    quote do
      use Timex
      require Logger
      alias TwitchDiscovery.Index

      def index_to_string(index) when is_integer(index) do
        Integer.to_string(index)
      end

      def index_to_string(index) do
        index
      end

      def request(), do: initial_url() |> request()
      def request(url) do
        case RestTwitch.Request.get_body(url) do
          {:ok, body} -> Poison.decode!(body)
          {:error, error} -> handle_request_error(url, error)
        end
      end

      def retry_request(url), do: request(url)

      def handle_request_error(url, error) do
        case error do
          %RestTwitch.Error{code: 404} -> :ok
          %RestTwitch.Error{code: 503} -> retry_request(url)
          _                            -> Logger.error "Unhandled error in Index.Base"
        end
      end

      def find(query, opts \\ []) do
        Mongo.find(MongoPool, collection_name(), query, opts)
        |> Enum.to_list
        |> filter_results()
      end

      def filter_results(results) do
        Stream.map(results, &map_result(&1))
        |> Enum.filter(fn (result)->
          nil != result
        end)
      end

      def map_result(result) do
        cached_result = db_key(result["id"])
        |> TwitchDiscovery.Index.redis_get()

        case cached_result do
          :undefined -> nil
          result -> Poison.decode!(result)
        end
      end

      def format_query(query, orderby \\ %{}) do
        %{"$query" => query, "$orderby" => orderby}
      end

      def params_to_query(params) do
        parse_params_to_query(params)
        |> format_query(sorting(params))
      end



      def redis_save_one(data, id) do
        :redis_client
        |> Process.whereis()
        |> Exredis.query(["SETEX", db_key(id), 3600, Poison.encode!(data)])
      end

      def redis_save_many(results) do
        Enum.each(results, fn (result) ->
          redis_save_one(result, result["_id"])
        end)
      end

      def save_to_redis(dataset) when is_list(dataset) do
        dataset |> redis_save_many()
      end

      def mongo_save(data, id) do
        try do
          case Mongo.insert_one(MongoPool, Index.get_processing_index() |> db_key(), data) do
            {:ok, _} -> :ok
            {:error, error} -> Logger.error error.message
          end
        rescue
          e in Mongo.Error -> e
        end
      end

      def save_to_mongo(documents) do
        mongo_save_many(documents)
      end

      def mongo_save_many([]), do: :ok
      def mongo_save_many(documents) do
        try do
          Mongo.insert_many(MongoPool, Index.get_processing_index() |> db_key(), documents, [ordered: false])
        rescue
          e in Mongo.Error -> Logger.error e.message
        end
      end
    end
  end
end