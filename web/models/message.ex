defmodule PhoenixChat.Message do
  use PhoenixChat.Web, :model

  schema "messages" do
    field :body, :string
    field :timestamp, PhoenixChat.DateTime
    field :room, :string
    field :from, :string
    belongs_to :user, PhoenixChat.User

    timestamps
  end

  @required_fields ~w(body timestamp room)
  @optional_fields ~w(user_id from)

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
