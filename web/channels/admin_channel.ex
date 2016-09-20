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
      send(self, :after_join)
      id = socket.assigns[:uuid] || socket.assigns[:user_id]
      lobby_list = AnonymousUser.recently_active_users |> Repo.all
      {:ok, %{id: id, lobby_list: lobby_list}, socket}
    end)
  end

  @doc """
  This handles the `:after_join` event and tracks the presence of the socket that
  has subscribed to the `admin:active_users` topic.
  """
  def handle_info(:after_join, %{assigns: %{user_id: _user_id}} = socket) do
    {:noreply, socket}
  end

  def handle_info(:after_join, %{assigns: %{uuid: uuid}} = socket) do
    user = ensure_user_saved!(uuid)

    broadcast! socket, "lobby_list", user

    push socket, "presence_state", Presence.list(socket)
    Logger.debug "Presence for socket: #{inspect socket}"
    {:ok, _} = Presence.track(socket, uuid, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end

  @doc """
  Sends the lobby_list only to admins
  """
  def handle_out("lobby_list", payload, socket) do
    assigns = socket.assigns
    if assigns[:user_id] do
      push socket, "lobby_list", payload
    end
    {:noreply, socket}
  end

  defp ensure_user_saved!(uuid) do
    user_exists = Repo.get(AnonymousUser, uuid)
    if user_exists do
      user_exists
    else
      changeset = AnonymousUser.changeset(%AnonymousUser{}, %{id: uuid})
      Repo.insert!(changeset)
    end
  end
end
