defmodule PhoenixChat.Message do
  use PhoenixChat.Web, :model

  alias PhoenixChat.{DateTime, User, AnonymousUser}

  schema "messages" do
    field :body, :string
    field :timestamp, DateTime
    field :room, :string

    belongs_to :user, User
    belongs_to :anonymous_user, AnonymousUser, type: :binary_id

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
