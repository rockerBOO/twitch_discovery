defmodule TwitchDiscovery.VideoTest do
  use TwitchDiscovery.ModelCase

  alias TwitchDiscovery.Video

  @valid_attrs %{broadcast_id: 42, channel_display_name: "some content", channel_name: "some content", description: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Video.changeset(%Video{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Video.changeset(%Video{}, @invalid_attrs)
    refute changeset.valid?
  end
end
