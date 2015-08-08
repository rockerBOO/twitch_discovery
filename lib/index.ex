defmodule TwitchDiscovery.Index do
  require Logger

  alias TwitchDiscovery.Index.Stream
  alias TwitchDiscovery.Index.Game

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

end