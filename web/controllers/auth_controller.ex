defmodule PhoenixChat.AuthController do
  use PhoenixChat.Web, :controller

  alias PhoenixChat.{ErrorView, UserView, User, AuthController}

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    result = with {:ok, user} <- user_from_auth(auth),
                  :ok <- validate_pass(user.encrypted_password, auth.credentials.other.password),
                  do: signin_user(conn, user)

    case result do
      {:ok, user, token} ->
        conn
        |> put_status(:created)
        |> render(UserView, "show.json", user: user, token: token)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> render(ErrorView, "error.json", error: reason)
    end
  end

  defp user_from_auth(auth) do
    result = Repo.get_by(User, email: auth.info.email)
    case result do
      nil -> {:error, %{"email" => ["invalid email"]}}
      user -> {:ok, user}
    end
  end

  defp validate_pass(_encrypted, password) when password in [nil, ""] do
    {:error, "password required"}
  end

  defp validate_pass(encrypted, password) do
    if Comeonin.Bcrypt.checkpw(password, encrypted) do
      :ok
    else
      {:error, "invalid password"}
    end
  end
end
