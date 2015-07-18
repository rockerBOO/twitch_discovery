defmodule TwitchDiscovery.Index.StreamTest do
  use TwitchDiscovery.ModelCase
  alias TwitchDiscovery.Index.Stream

  test "parse_params_to_query" do

  end

  test "fail to get results from twitch, continue" do
    json = """
    {"streams":[],"_total":18357,"_links":{"self":"https://api.twitch.tv/kraken/streams?limit=1&offset=7900","next":"https://api.twitch.tv/kraken/streams?limit=1&offset=7901","prev":"https://api.twitch.tv/kraken/streams?limit=1&offset=7899","featured":"https://api.twitch.tv/kraken/streams/featured","summary":"https://api.twitch.tv/kraken/streams/summary","followed":"https://api.twitch.tv/kraken/streams/followed"}}
    """
    assert false == Poison.decode!(json)
    |> Stream.is_last?()

    json = """
    {"streams":[],"_total":7902,"_links":{"self":"https://api.twitch.tv/kraken/streams?limit=1&offset=7900","next":"https://api.twitch.tv/kraken/streams?limit=1&offset=7901","prev":"https://api.twitch.tv/kraken/streams?limit=1&offset=7899","featured":"https://api.twitch.tv/kraken/streams/featured","summary":"https://api.twitch.tv/kraken/streams/summary","followed":"https://api.twitch.tv/kraken/streams/followed"}}
    """

    assert false == Poison.decode!(json)
    |> Stream.is_last?()

    json = """
    {"streams":[],"_total":7850,"_links":{"self":"https://api.twitch.tv/kraken/streams?limit=1&offset=7900","next":"https://api.twitch.tv/kraken/streams?limit=1&offset=7901","prev":"https://api.twitch.tv/kraken/streams?limit=1&offset=7899","featured":"https://api.twitch.tv/kraken/streams/featured","summary":"https://api.twitch.tv/kraken/streams/summary","followed":"https://api.twitch.tv/kraken/streams/followed"}}
    """

    assert true == Poison.decode!(json)
    |> Stream.is_last?()
  end

  test "parse_mature" do
    assert Stream.parse_mature("yes") == true

    assert Stream.parse_mature("no") == false

    assert Stream.parse_mature("all") == nil

    assert Stream.parse_mature("true") == nil

    assert Stream.parse_mature(false) == nil
  end

  test "parse_fps" do
    assert Stream.parse_fps("30") == [28, 30]

    assert Stream.parse_fps("60") == [58, 60]

    assert Stream.parse_fps("All") == []

    assert Stream.parse_fps("all") == []

    assert Stream.parse_fps("45") == [43, 45]

    assert Stream.parse_fps(60) == [58, 60]

    assert Stream.parse_fps(45) == [43, 45]
  end

  test "parse_viewers" do
    assert Stream.parse_viewers("500") == 500

    assert Stream.parse_viewers(500) == 500

    assert Stream.parse_viewers(nil) == nil

    assert Stream.parse_viewers("Any") == nil
  end

  test "parse_game" do
    assert Stream.parse_game("") == nil
    assert Stream.parse_game(nil) == nil
    assert Stream.parse_game("Minecraft") == "Minecraft"
  end


  test "db_key" do
    assert Stream.db_key(1) == "streams-1"

    assert Stream.db_key("1") == "streams-1"

    assert Stream.db_key(0) == "streams-0"

    assert Stream.db_key(2) == "streams-2"

    assert Stream.db_key(3) == "streams-3"
  end

  test "parse started at to timestamp" do
    assert Stream.parse_started_at_to_offset("m5") == {:mins, 5}

    assert Stream.parse_started_at_to_offset("h5") == {:hours, 5}

    assert Stream.parse_started_at_to_offset("h24") == {:hours, 24}

    assert Stream.parse_started_at_to_offset("m32") == {:mins, 32}

    assert Stream.parse_started_at_to_offset("Just now!") == {:mins, 5}
  end

  test "sorting" do
    assert Stream.sorting(%{"started_at" => "All"}) == %{"viewers" => -1}
    assert Stream.sorting(%{"uptime" => "Now"}) == %{"started_at" => -1}
    assert Stream.sorting(%{"started_at" => "Any"}) == %{"started_at" => -1}
    assert Stream.sorting(%{"started_at" => "2 hours ago"}) == %{"started_at" => -1}
  end
end
