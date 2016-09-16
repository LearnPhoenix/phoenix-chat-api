defmodule PhoenixChat.Message do
  use PhoenixChat.Web, :model

  alias PhoenixChat.{DateTime}

  # @derive is a module attribute for you to be able to customize how an
  # Elixir Protocol treats a custom struct.
  # In this case, we instruct the Poison.Encode protocol to only encode
  # certain fields and ignore the rest.
  # More info at:
  # - https://github.com/devinus/poison#encoding-only-some-attributes
  #
  # This replaces the message_payload/1 function in RoomChannel
  @derive {Poison.Encoder, only: ~w(id body timestamp room user_id anonymous_user_id)a}

  schema "messages" do
    field :body, :string
    field :timestamp, DateTime
    field :room, :string

    belongs_to :user, PhoenixChat.User
    # Note that we set `:type` below. This is so Ecto is aware the type of the
    # foreign_key is not an `:integer` but a `:binary_id`.
    belongs_to :anonymous_user, PhoenixChat.AnonymousUser, type: :binary_id

    timestamps
  end

  @required_fields ~w(body timestamp room)
  @optional_fields ~w(anonymous_user_id user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @doc """
  An `Ecto.Query` that returns the last 10 message records for a given room.
  """
  def latest_room_messages(room, number \\ 10) do
    from m in __MODULE__,
         where: m.room ==  ^room,
         order_by: [desc: :timestamp],
         limit: ^number
  end
end
