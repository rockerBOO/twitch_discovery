defmodule TwitchDiscovery.Index.Stream do
  use TwitchDiscovery.Index.Base
  alias TwitchDiscovery.Parser.Stream
  alias TwitchDiscovery.Parser.Broadcast

  def db_key(index) do
    "streams-" <> index_to_string(index)
  end

  def db_key() do
    "streams-" <> Index.get_current_index()
  end

  def parse_filters(dataset) do
    dataset
    |> Map.fetch!("streams")
    |> Enum.map(fn (stream) ->
      Stream.process(stream)
    end)
  end

  def data_length(dataset) do
    length(dataset["streams"])
  end

  def initial_url do
    "/streams?limit=100"
  end

  def collection_name() do
    TwitchDiscovery.Index.get_current_index()
    |> collection_name()
  end

  def collection_name(index) do
    "streams-" <> index
  end

  def save(mongo_results, dataset) do
    dataset
    |> Map.fetch!("streams")
    |> Enum.each(fn (result) ->
      redis_save(result, result["_id"])
    end)

    mongo_save_many(mongo_results)
  end

  def parse_params_to_query(params) do
    mature = case params["mature"] do
      "yes" -> true
      "no"  -> false
      "all" -> nil
      _     -> nil
    end

    fps = case params["fps"] do
      "30"  -> [28, 30]
      "60"  -> [58, 60]
      "All" -> []
      _     -> []
    end

    query = %{}

    IO.puts "mature"
    IO.inspect mature

    if mature == true or mature == false do
      query = Map.put(query, "mature", mature)
    end

    IO.inspect query

    if fps != [] do
      fps_query = case fps do
        [min, max] -> %{"$gt" => min, "$lt" => max}
      end

      query = Map.put(query, "fps", fps_query)
    end

    IO.inspect query

    if params["game"] != "" and params["game"] != nil do
      query = Map.put(query, "game", params["game"])
    end

    IO.inspect query

    case params["viewers"] do
      nil -> 0
      x when x > 0 ->
        viewers = case Integer.parse(x) do
          {viewers, _} -> viewers
          :error -> nil
        end

        if viewers != nil do
          query = Map.put(query, "viewers", %{"$lt" => viewers})
        end
      _ -> :ok
    end

    if params["uptime"] do
      date_now = Date.now

      timestamp = case params["uptime"] do
        <<"m", min::binary>> ->
          {mins, _} = Integer.parse(min)
          %{mins: mins}
        <<"h", hour::binary>> ->
          {hours, _} = Integer.parse(hour)
          %{hours: hours}
        "Just now!" -> date_now |> Date.shift(mins: 5)
        _ -> %{}
      end

      datetime = case timestamp do
        %{mins: mins} -> date_now |> Date.subtract(Time.to_timestamp(mins, :mins))
        %{hours: hours} -> date_now |> Date.subtract(Time.to_timestamp(hours, :hours))
        %{} -> nil
      end

      if datetime do
        # GET THE SECONDS OUT
        {:ok, min_uptime} = DateFormat.format(datetime, "{s-epoch}")
        {min_uptime, _} = Integer.parse(min_uptime)

        query = case min_uptime do
          0 -> query
          uptime -> Map.put(query, "started_at", %{"$lt" => uptime})
        end
      end
    end

    if params["started_at"] do
      date_now = Date.now

      timestamp = case params["started_at"] do
        <<"m", min::binary>> ->
          {mins, _} = Integer.parse(min)
          %{mins: mins}
        <<"h", hour::binary>> ->
          {hours, _} = Integer.parse(hour)
          %{hours: hours}
        "Just now!" -> date_now |> Date.shift(mins: 5)
        _ -> %{}
      end

      datetime = case timestamp do
        %{mins: mins} -> date_now |> Date.subtract(Time.to_timestamp(mins, :mins))
        %{hours: hours} -> date_now |> Date.subtract(Time.to_timestamp(hours, :hours))
        %{} -> nil
      end

      if datetime do
        # GET THE SECONDS OUT
        {:ok, min_uptime} = DateFormat.format(datetime, "{s-epoch}")
        {min_uptime, _} = Integer.parse(min_uptime)

        query = case min_uptime do
          0 -> query
          uptime -> Map.put(query, "started_at", %{"$lt" => uptime})
        end
      end
    end

    IO.puts Poison.encode!(query)
    IO.inspect query

    query
  end

  def sorting(params) do
    case params do
      %{"started_at" => "All"} -> %{"viewers" => -1}
      %{"uptime" => _} -> %{"started_at" => -1}
      %{"started_at" => _} -> %{"started_at" => -1}
      _ -> %{"viewers" => -1}
    end
  end

  def map_result(result) do
    result = db_key(result["id"])
    |> TwitchDiscovery.Index.redis_get()

    case result do
      :undefined -> nil
      result -> result |> Poison.decode!()
    end
  end
end