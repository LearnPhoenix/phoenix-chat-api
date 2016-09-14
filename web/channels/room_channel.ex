defmodule PhoenixChat.RoomChannel do
  use PhoenixChat.Web, :channel
  require Logger

  def join("room:" <> _uid, payload, socket) do
    authorize(payload, fn ->
      {:ok, socket}
    end)
  end

  def handle_in("message", payload, socket) do
    Logger.debug "#{inspect payload}"
    broadcast socket, "message", payload
    {:noreply, socket}
  end
end
