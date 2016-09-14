defmodule PhoenixChat.AdminChannel do
  @moduledoc """
  The channel used to give the administrator access to all users.
  """

  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Presence}

  @doc """
  The `admin:active_users` topic is how we identify all users currently using the app.
  """
  def join("admin:active_users", payload, socket) do
    authorize(payload, fn ->
      send(self, :after_join)
      {:ok, socket}
    end)
  end

  @doc """
  This handles the `:after_join` event and tracks the presence of the socket that has subscribed to the `admin:active_users` topic.
  """
  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    Logger.debug "Presence for socket: #{inspect socket}"
    id = socket.assigns.user_id || socket.assigns.uuid
    {:ok, _} = Presence.track(socket, id, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end
end
