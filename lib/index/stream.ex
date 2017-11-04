defmodule TwitchDiscovery.Index.Stream do
  use TwitchDiscovery.Index.Base
  alias TwitchDiscovery.Parser.Stream
  alias TwitchDiscovery.Parser.Broadcast
  alias TwitchDiscovery.Index.Game

  @name "streams"

  def db_key(index) do
    db_key(@name, index)
  end

  def db_key() do
    db_key(@name)
  end

  def collection_name(), do: get_current_index() |> collection_name()

  def collection_name(index),
  do: collection_name(@name, index)

  def get_current_index do
    get_current_index(@name)
  end

  def get_processing_index, do: get_processing_index(@name)
  def set_index(index), do: set_index(@name, index)

  # Handling finished results and errors due to empty results
  def process(%{"streams" => []} = resultset) do
    if is_last?(resultset) do
      finish_indexing()
    else
      Logger.info "Processing failed to get results, and not at the end."
      :timer.sleep(500)
      spawn(fn ->
        request(resultset["_links"]["next"])
        |> process()
      end)
    end
  end

  def process(resultset) when is_map(resultset) do
    resultset
    |> Map.fetch!("streams")
    |> save_to_redis()

    resultset
    |> Map.fetch!("streams")
    |> parse_filters()
    |> save_to_mongo()

    :timer.sleep(500)
    spawn(fn ->
      request(resultset["_links"]["next"])
      |> process()
    end)
  end

  def map_result(result) do
    map_result(result, "id")
  end

  def parse_filters(dataset) do
    dataset
    |> Enum.map(fn (stream) ->
      # TwitchDiscovery.Metric.Channel.save(stream["channel"]["name"], "viewers", stream["viewers"])
      Stream.process(stream)
    end)
  end

  def data_length(resultset) do
    length(resultset["streams"])
  end

  def initial_url do
    "/streams?limit=100"
  end

  def parse_language(language) do
    json = """
    {"en":"English","zh":"中文","ja":"日本語","ko":"한국어","es":"Español","fr":"Français","de":"Deutsch","it":"Italiano","pt":"Português","sv":"Svenska","no":"Norsk","da":"Dansk","nl":"Nederlands","fi":"Suomi","pl":"Polski","ru":"Русский","tr":"Türkçe","cs":"Čeština","sk":"Slovenčina","hu":"Magyar","ar":"العربية","bg":"Български","th":"ภาษาไทย","vi":"Tiếng Việt","other":"Other"}
    """

    case Poison.decode!(json) |> Map.fetch(language) do
      {:ok, _} -> language
      :error   -> nil
    end
  end

  def parse_mature(mature) do
    case mature do
      "yes" -> true
      "no"  -> false
      "all" -> nil
      _     -> nil
    end
  end

  def parse_fps("30"), do: [28, 30]
  def parse_fps("60"), do: [58, 60]
  def parse_fps("All"), do: []
  def parse_fps(fps) do
    case fps do
      fps when is_integer(fps) ->
               [fps-2, fps]

      fps when is_bitstring(fps) ->
        case Integer.parse(fps) do
          {int, _} -> [int-2, int]
          :error -> []
        end
      _     -> []
    end
  end

  def parse_viewers(min, max) do
    min = parse_viewers(min)
    max = parse_viewers(max)

    [min, max]
  end

  def parse_viewers(nil), do: nil
  def parse_viewers("Any"), do: nil
  def parse_viewers(viewers) do
    case viewers do
      x when x > 0 and is_bitstring(x) ->
        {int, _} = Integer.parse(x)
        int
      x when x > 0 -> x
      _            -> 0
    end
  end

  def parse_game(""), do: nil
  def parse_game(nil), do: nil
  def parse_game(game) do
    game
  end

  def parse_started_at_to_offset(<<"m", min::binary>>) do
    {:mins, string_to_integer(min)}
  end

  def parse_started_at_to_offset(<<"h", hours::binary>>) do
    {:hours, string_to_integer(hours)}
  end

  def parse_started_at_to_offset("Just now!"), do: {:mins, 5}
  def parse_started_at_to_offset(_), do: nil

  def parse_started_at(uptime) do
    datetime = case parse_started_at_to_offset(uptime) do
      {:mins, mins} -> Timex.now |> Timex.shift(minutes: mins)
      {:hours, hours} -> Timex.now |> Timex.shift(hours: hours)
      nil -> nil
    end

    if datetime == nil do
      nil
    else
      {:ok, min_uptime} = Timex.format(datetime, "{s-epoch}")
      {min_uptime, _} = Integer.parse(min_uptime)

      min_uptime
    end
  end

  def string_to_integer(string) do
    case Integer.parse(string) do
      {int, _} -> int
      :error -> nil
    end
  end

  def parse_params_to_query(params) do
    mature     = params["mature"]     |> parse_mature()
    fps        = params["fps"]        |> parse_fps()
    game       = params["game"]       |> parse_game()
    started_at = params["started_at"] |> parse_started_at()
    language   = params["language"]   |> parse_language()

    [viewers_min, viewers_max] = parse_viewers(params["viewers_min"], params["viewers_max"])

    query = %{}

    if mature == true or mature == false do
      query = Map.put(query, "mature", mature)
    end

    if fps != [] do
      fps_query = case fps do
        [min, max] -> %{"$gt" => min, "$lt" => max}
      end

      query = Map.put(query, "fps", fps_query)
    end

    if game != nil do
      query = Map.put(query, "game", params["game"])
    end

    if viewers_min != nil && viewers_max != nil do
      query = Map.put(query, "viewers", %{"$lt" => viewers_max, "$gt" => viewers_min})
    end

    if language != nil do
      query = Map.put(query, "language", language)
    end

    if started_at != nil do
      query = case started_at do
        0 -> query
        started_at -> Map.put(query, "started_at", %{"$lt" => started_at})
      end
    end

    IO.puts Poison.encode!(query)

    query
  end

  def sorting(params) do
    case params do
      %{"started_at" => "All"} -> %{"viewers" => -1}
      %{"uptime" => _}         -> %{"started_at" => -1}
      %{"started_at" => _}     -> %{"started_at" => -1}
      _                        -> %{"viewers" => -1}
    end
  end

end
