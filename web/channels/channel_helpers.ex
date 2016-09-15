defmodule PhoenixChat.ChannelHelpers do
  @moduledoc """
  Convenience functions imported in all Channels
  """

  alias PhoenixChat.{AnonymousUser, Repo, Message}

  @doc """
  Convenience function for authorization
  """
  def authorize(payload, fun, custom_authorize \\ nil) do
    check_authorization = custom_authorize || &authorized?/1
    if check_authorization.(payload) do
      fun.()
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc """
  Function that determines authorization logic. If `true`, all users will be authorized.
  """
  def authorized?(_payload) do
    true
  end

  @doc """
  Returns an anonymous user record.

  This either gets or creates an anonymous user with the `uuid` from `socket.assigns.`.
  """
  def get_or_create_anonymous_user!(%{uuid: uuid} = assigns) do
    if user = Repo.get(AnonymousUser, uuid) do
      user
    else
      params = %{public_key: assigns.public_key, id: uuid}
      changeset = AnonymousUser.changeset(%AnonymousUser{}, params)
      Repo.insert!(changeset)
    end
  end

  # We do not need to create signed-up users
  def get_or_create_anonymous_user!(_socket), do: nil #noop

  def user_payload(list) when is_list(list) do
    Enum.map(list, &user_payload/1)
  end

  def user_payload({user, message}) do
    %{name: user.name,
      avatar: user.avatar,
      id: user.id,
      public_key: user.public_key,
      last_viewed_by_admin_at: user.last_viewed_by_admin_at,
      last_message: message && message.body,
      last_message_sent_at: message && message.inserted_at}
  end

  def user_payload(user) do
    message = Message.latest_room_messages(user.id, 1) |> Repo.one
    user_payload({user, message})
  end
end
