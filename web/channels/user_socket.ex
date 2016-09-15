defmodule PhoenixChat.UserSocket do
  use Phoenix.Socket

  alias PhoenixChat.{Repo, User}

  ## Channels
  channel "room:*", PhoenixChat.RoomChannel
  channel "admin:*", PhoenixChat.AdminChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket) do
    user_id = params["id"]
    user = user_id && Repo.get(User, user_id)

    socket = if user do
        socket
        |> assign(:user_id, user_id)
        |> assign(:username, user.username)
        |> assign(:email, user.email)
      else
        socket
        |> assign(:user_id, nil)
        |> assign(:uuid, params["uuid"])
      end
        |> assign(:public_key, params["public_key"])

    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PhoenixChat.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
