defmodule PhoenixChat.AnonymousUser do
  use PhoenixChat.Web, :model

  alias PhoenixChat.Message

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "anonymous_users" do
    field :name
    field :avatar
    has_many :messages, Message

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(id), ~w())
    |> put_avatar
    |> put_name
  end

  @doc """
  This query returns users with the most recent messages up to a given limit.
  """
  def recently_active_users(limit \\ 20) do
    from u in __MODULE__,
      left_join: m in Message, on: m.anonymous_user_id == u.id,
      distinct: u.id,
      order_by: [desc: u.inserted_at, desc: m.inserted_at],
      limit: ^limit
  end

  defp put_name(changeset) do
    adjective = Faker.Color.name |> String.capitalize
    noun = Faker.Company.buzzword_suffix |> String.capitalize
    name = adjective <> " " <> noun
    changeset
    |> put_change(:name, name)
  end

  defp put_avatar(changeset) do
    changeset
    |> put_change(:avatar, Faker.Avatar.image_url(25, 25))
  end
end
