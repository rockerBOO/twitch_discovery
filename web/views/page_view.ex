defmodule TwitchDiscovery.PageView do
  use TwitchDiscovery.Web, :view

  def has_previous?(conn, dataset) do
    # @conn.query_string |> URI.query_decoder
    true
  end

  def get_limit(conn, default) do
    limit = pull_limit_from_query_string(conn.query_string)

    case limit do
      x when is_integer(x) -> x
      _ -> default
    end
  end

  def get_offset(conn, default) do
    limit = pull_offset_from_query_string(conn.query_string)

    case limit do
      x when is_integer(x) -> x
      _ -> default
    end
  end

  def pull_limit_from_query_string(query_string) do
    pull_key_from_query_string(query_string, "limit")
  end

  def pull_offset_from_query_string(query_string) do
    pull_key_from_query_string(query_string, "offset")
  end

  def pull_key_from_query_string(query_string, key) do
    case find_in_query_string(query_string, key) do
      [{key, value}] -> value
      [] -> nil
    end
  end

  def find_in_query_string(query_string, key) do
    query_string
      |> URI.query_decoder()
      |> Enum.map(&(&1))
      |> Enum.reject(fn ({k, v}) ->
          k != key
        end)
  end

  def is_first?(conn) do
    case pull_limit_from_query_string(conn.query_string) do
      0 -> true
      _ -> false
    end
  end
end
