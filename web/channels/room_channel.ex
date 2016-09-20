defmodule PhoenixChat.RoomChannel do
  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Message, Repo}

  def join("room:" <> room_id, payload, socket) do
    authorize(payload, fn ->
      messages = room_id
        |> Message.latest_room_messages
        |> Repo.all
        |> Enum.reverse
      {:ok, %{messages: messages}, socket}
    end)
  end

  def handle_in("message", payload, socket) do
    payload = payload
      |> Map.put("user_id", socket.assigns.user_id)
      |> Map.put("from", socket.assigns[:uuid])
    changeset = Message.changeset(%Message{}, payload)

    case Repo.insert(changeset) do
      {:ok, message} ->
        payload = message_payload(message)
        broadcast! socket, "message", payload
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp message_payload(message) do
    from = message.user_id || message.from
    %{body: message.body,
      timestamp: message.timestamp,
      room: message.room,
      from: from,
      id: message.id}
  end
end
