defmodule TwitchDiscovery.IndexTest do
  use TwitchDiscovery.ModelCase

  alias TwitchDiscovery.Index.Stream

  test "index_to_string" do
    assert Stream.index_to_string(10) == "10"

    assert Stream.index_to_string("10") == "10"
  end

  test "format_query" do
    query = Stream.format_query(%{"game" => "Minecraft"}, %{"started_at" => %{"$lt" => 16472389}})

    assert query == %{
      "$query" => %{"game" => "Minecraft"},
      "$orderby" => %{"started_at" => %{"$lt" => 16472389}}
    }
  end

  test "params_to_query" do

  end

end
