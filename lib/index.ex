defmodule TwitchDiscovery.Index do
  require Logger

  alias TwitchDiscovery.Index.Stream
  alias TwitchDiscovery.Index.Game

  def redis_client() do
    :redis_client |> Process.whereis()
  end

  def redis_get(key) do
    redis_client() |> Exredis.query(["GET", key])
  end

  def get_current_index() do
    case redis_get("index_index") do
      :undefined -> 0
      index -> index
    end
  end

  def get_processing_index() do
    case redis_get("index_index") do
      "2" -> 0
      "1" -> 2
      "0" -> 1
      :undefined -> 1
    end
  end

  def set_index(id) do
    IO.puts "set_index " <> Integer.to_string(id)

    redis_client() |> Exredis.query(["SET", "index_index", id])
  end

  def index do
    Logger.info "Index all live streams"

    spawn(fn ->
      Stream.request()
      |> Stream.process()
    end)

    index_games()
  end

  def index_games do
    Logger.info "Index all games"

    spawn(fn ->
      Game.request()
      |> Game.process()
    end)
  end

  def finish do
    increment_mongo_index()
  end

  def increment_mongo_index() do
    current_index = get_current_index()
    processing_index = get_processing_index()

    set_index(processing_index)
  end
end