defmodule TwitchDiscovery.PageControllerTest do
  use TwitchDiscovery.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Discovery!"
  end
end
