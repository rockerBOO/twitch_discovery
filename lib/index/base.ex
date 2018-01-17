# TwitchDiscovery.Index.index

defmodule TwitchDiscovery.Index.Base do
  defmacro __using__(_) do
    quote do
      use Timex
      require Logger
      alias TwitchDiscovery.Index

      def db_key(name, index) do
        "#{name}-" <> index_to_string(index)
      end

      def db_key(name) do
        "#{name}-" <> get_current_index()
      end

      def collection_name(), do: get_current_index() |> collection_name()

      def collection_name(name, index), do: "#{name}-#{index}"

      def get_current_index(type) do
        case redis_get(type <> "_index") do
          :undefined -> 0
          index -> index
        end
      end

      def get_processing_index(type) do
        case redis_get(type <> "_index") do
          "2" -> 0
          "1" -> 2
          "0" -> 1
          :undefined -> 1
        end
      end



      def index_to_string(index) when is_integer(index) do
        Integer.to_string(index)
      end

      def index_to_string(index) do
        index
      end

      def set_index(type, id) do
        IO.puts "set_index '#{type}_index' " <> Integer.to_string(id)

        redis_client() |> Exredis.query(["SET", type <> "_index", id])
      end

      def finish_indexing do
        Logger.info "Finished indexing games"

        current_index = get_current_index()

        finish()

        Mongo.delete_many(
          :mongo,
          current_index |> collection_name(),
          %{}, 
          pool: DBConnection.Poolboy
        )
      end

      def finish() do
        increment_index()
      end

      def increment_index() do
        current_index = get_current_index()
        processing_index = get_processing_index()

        set_index(processing_index)
      end

      def redis_client() do
        :redis_client |> Process.whereis()
      end

      def redis_get(key) do
        redis_client() |> Exredis.query(["GET", key])
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
        try do
          Mongo.find(:mongo, collection_name(), query, Enum.into(opts, pool: DBConnection.Poolboy))
          |> Enum.to_list
          |> filter_results()
        rescue
          e in Mongo.Error -> Logger.error e.message
        end
      end

      def filter_results(results) do
        Stream.map(results, &map_result(&1))
        |> Enum.filter(fn (result)->
          nil != result
        end)
      end

      def map_result(result, unique_field) do
        cached_result = db_key(result[unique_field]) |> redis_get()

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

      def is_last?(resultset) do
        total = resultset["_total"]

        [{"limit", limit}, {"offset", offset}, _] =
          URI.parse(resultset["_links"]["self"])
          |> Map.fetch!(:query)
          |> URI.query_decoder
          |> Enum.to_list

        String.to_integer(offset) + String.to_integer(limit) > total
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
          case Mongo.insert_one(:mongo, get_processing_index() |> db_key(), data) do
            {:ok, _} -> :ok
            {:error, error} -> Logger.error error.message
          end
        rescue
          e in Mongo.Error -> Logger.error e.message
        end
      end

      def save_to_mongo(documents) do
        mongo_save_many(documents)
      end

      def mongo_save_many([]), do: :ok
      def mongo_save_many(documents) do
        try do
          Mongo.insert_many(:mongo, get_processing_index() |> db_key(), documents, [ordered: false, pool: DBConnection.Poolboy])
        rescue
          e in Mongo.Error -> Logger.error e.message
        end
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end