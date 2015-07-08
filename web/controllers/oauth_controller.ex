defmodule TwitchDiscovery.OAuthController do
  use TwitchDiscovery.Web, :controller

  plug :action

  @doc """
  This action is reached via `/auth` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def auth(conn, _params) do
    redirect conn, external: OAuth2.Twitch.authorize_url!
  end

  @doc """
  This action is reached via `/auth/callback` is the the callback URL that
  the OAuth2 provider will redirect the user back to with a `code` that will
  be used to request an access token. The access token will then be used to
  access protected resources on behalf of the user.
  """
  def callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    token = OAuth2.Twitch.get_token!([code: code])

    user_info(token)

    save(conn, token)

    conn
  end

  defp user_info(token) do
    # Request the user's data with the access token
    headers = [{"Authorization", "OAuth " <> token.access_token}]

    OAuth2.Twitch.get!("/user", headers)
  end

  def error(conn, error, message) do
    IO.puts "#{error} !!! #{message}"

    conn
  end

  def save(conn, token) do
    IO.inspect token

    conn
      |> put_session(:access_token, token)
      |> redirect(to: "/?auth=ok")
  end
end
