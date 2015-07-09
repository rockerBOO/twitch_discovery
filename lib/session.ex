defmodule TwitchDiscovery.Session do
  def current_user(conn) do
    Plug.Conn.get_session(conn, :current_user)
  end

  def logged_in?(conn), do: !!current_user(conn)
end