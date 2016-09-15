defmodule PhoenixChat.AdminChannel do
  @moduledoc """
  The channel used to give the administrator access to all users.
  """

  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Presence, Repo, AnonymousUser}

  intercept ~w(lobby_list)

  @doc """
  The `admin:active_users` topic is how we identify all users currently using the app.
  """
  def join("admin:active_users", payload, socket) do
    authorize(payload, fn ->
      public_key = socket.assigns.public_key
      lobby_list = public_key
        |> AnonymousUser.by_public_key
        |> Repo.all
        |> user_payload
      send(self, :after_join)
      {:ok, %{lobby_list: lobby_list}, socket}
    end)
  end

  @doc """
  This handles the `:after_join` event and tracks the presence of the socket that
  has subscribed to the `admin:active_users` topic.
  """
  def handle_info(:after_join, socket) do
    track_presence(socket, socket.assigns)
    {:noreply, socket}
  end

  @doc """
  Sends the lobby_list only to admins
  """
  def handle_out("lobby_list", payload, socket) do
    %{assigns: assigns} = socket
    if assigns.user_id && assigns.public_key == payload.public_key do
      push socket, "lobby_list", payload
    end
    {:noreply, socket}
  end

  defp track_presence(socket, %{uuid: uuid}) do
    user = get_or_create_anonymous_user!(uuid)

    payload = user_payload(user)
    # Keep track of rooms to be displayed to admins
    broadcast! socket, "lobby_list", payload
    # Keep track of users that are online (not keepin track of admin presence)
    push socket, "presence_state", Presence.list(socket)
    Logger.debug "Presence for socket: #{inspect socket}"

    {:ok, _} = Presence.track(socket, uuid, %{
      online_at: inspect(System.system_time(:seconds))
    })
  end

  defp track_presence(_socket, _), do: nil #noop
end
