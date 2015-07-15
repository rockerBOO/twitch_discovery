defmodule TwitchDiscovery.BroadcastController do
  use     TwitchDiscovery.Web, :controller
  use     Timex
  import  ExPrintf
  alias   TwitchDiscovery.Index.Broadcast
  require Logger

  defmodule Error do
    defexception reason: ""
  end

  def index(conn, params) do
    broadcasts = Broadcast.params_to_query(params)
    |> Broadcast.find(limit: 24)

    render conn, "broadcasts.html", broadcasts: broadcasts, params: params
  end
end


