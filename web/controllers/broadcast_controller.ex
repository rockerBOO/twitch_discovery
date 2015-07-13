defmodule TwitchDiscovery.BroadcastController do
  use TwitchDiscovery.Web, :controller
  use Timex

  import ExPrintf

  alias TwitchDiscovery.Indexer.Broadcast
  require Logger

  defmodule Error do
    defexception reason: ""
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

    IO.inspect mature

    if mature == "yes" or mature == "no" do
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

    IO.inspect query

    query
  end

  def sorting(params) do
    case params do
      %{"uptime" => _} -> %{"started_at" => -1}
      %{"started_at" => _} -> %{"started_at" => 1}
      _ -> %{"viewers" => -1}
    end
  end

  def index(conn, params) do
	  index = Broadcast.get_current_index()

    Logger.debug "Querying data from broadcasts-" <> Integer.to_string(index)

    # {:ok, mongo} = Mongo.Connection.start_link(database: "discovery")

    collection = "broadcasts-" <> Integer.to_string(index)

    query = %{
      "$query" => parse_params_to_query(params),
      "$orderby" => sorting(params)
    }

    broadcasts = Mongo.find(MongoPool, collection, query)
      |> Enum.to_list
      |> Enum.map(fn (result) ->
          Broadcast.db_key(result["id"])
            |> Broadcast.redis_get()
            |> Poison.decode!()
        end)
      # |> IO.inspect

    # broadcasts = Enum.to_list results

    render conn, "broadcasts.html", broadcasts: broadcasts, params: params
  end
end


