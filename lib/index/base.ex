# TwitchDiscovery.Index.index

defmodule TwitchDiscovery.Index.Base do
  defmacro __using__(_) do
    quote do
      require Logger
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
    end
  end
end