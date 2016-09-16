defmodule PhoenixChat.AdminChannel do
  @moduledoc """
  The channel used to give the administrator access to all users.
  """

  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Presence, Repo, AnonymousUser}

  @doc """
  The `admin:active_users` topic is how we identify all users currently using the app.
  """
  def join("admin:active_users", payload, socket) do
    authorize(payload, fn ->
      send(self, :after_join)
      id = socket.assigns[:uuid] || socket.assigns[:user_id]
      {:ok, %{id: id}, socket}
    end)
  end

  @doc """
  This handles the `:after_join` event and tracks the presence of the socket that
  has subscribed to the `admin:active_users` topic.
  """
  # We no longer track admin's presence. This will lead to simpler code in the
  # frontend by not having to filter out admin from the list of users in the Sidebar.
  def handle_info(:after_join, %{assigns: %{user_id: _user_id}} = socket) do
    {:noreply, socket}
  end

  # We track only the presence of anonymous users and ensure they are stored
  # in our DB.
  def handle_info(:after_join, %{assigns: %{uuid: uuid}} = socket) do
    # We save anonymous user to DB when it hasn't been saved before
    ensure_user_saved!(uuid)

    push socket, "presence_state", Presence.list(socket)
    Logger.debug "Presence for socket: #{inspect socket}"
    {:ok, _} = Presence.track(socket, uuid, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end

  defp ensure_user_saved!(uuid) do
    user_exists = Repo.get(AnonymousUser, uuid)
    unless user_exists do
      changeset = AnonymousUser.changeset(%AnonymousUser{}, %{id: uuid})
      Repo.insert!(changeset)
    end
  end
end
