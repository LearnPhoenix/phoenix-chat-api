defmodule PhoenixChat.RoomChannel do
  use PhoenixChat.Web, :channel
  require Logger

  alias PhoenixChat.{Message, Repo, Endpoint, AnonymousUser}

  def join("room:" <> room_id, payload, socket) do
    authorize(payload, fn ->
      messages = room_id
        |> Message.latest_room_messages
        |> Repo.all
        |> Enum.map(&message_payload/1)
        |> Enum.reverse
      send(self, {:after_join, payload})
      {:ok, %{messages: messages}, socket}
    end)
  end

  def handle_info({:after_join, payload}, socket) do
    # We create the anonymous user in our DB if its `uuid` does not match
    # any existing record.
    get_or_create_anonymous_user!(socket)

    # We record when admin views a room
    update_last_viewed_at(payload["previousRoom"])
    update_last_viewed_at(payload["nextRoom"])
    {:noreply, socket}
  end

  def handle_in("message", payload, socket) do
    payload = payload
      |> Map.put("user_id", socket.assigns.user_id)
      |> Map.put("from", socket.assigns[:uuid])
    changeset = Message.changeset(%Message{}, payload)

    case Repo.insert(changeset) do
      # This branch gets triggered when a message is sent by an anonymous user
      {:ok, %{anonymous_user_id: uuid} = message} when not is_nil(uuid) ->
        user = Repo.preload(message, :anonymous_user).anonymous_user
        message_payload = message_payload(message, user)
        broadcast! socket, "message", message_payload

        # Apart from sending the message, we want to update the lobby list
        # with the last message sent by the user and its timestamp
        Endpoint.broadcast_from! self, "admin:active_users",
          "lobby_list", user_payload({user, message})

        # We also send the message via the "notifications" event. This event
        # will be listened to in the frontend and will publish an Notification
        # via the browser when admin is not viewing the sender's chatroom.
        Endpoint.broadcast_from! self, "admin:active_users",
          "notifications", message_payload

      # This branch gets triggered when a message is sent by admin
      {:ok, message} ->
        broadcast! socket, "message", message_payload(message)
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp update_last_viewed_at(nil), do: nil #noop

  defp update_last_viewed_at(uuid) do
    user = Repo.get(AnonymousUser, uuid)
    changeset = AnonymousUser.last_viewed_changeset(user)
    user = Repo.update!(changeset)
    Endpoint.broadcast_from! self, "admin:active_users",
      "lobby_list", user_payload(user)
  end

  defp message_payload(%{anonymous_user_id: nil} = message) do
    %{body: message.body,
      timestamp: message.timestamp,
      room: message.room,
      from: message.user_id,
      id: message.id}
  end

  defp message_payload(message, user \\ nil) do
    user = user || Repo.preload(message, :anonymous_user).anonymous_user
    %{body: message.body,
      timestamp: message.timestamp,
      room: message.room,
      from: user.name,
      uuid: user.id,
      id: message.id}
  end
end
