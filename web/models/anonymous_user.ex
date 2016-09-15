defmodule PhoenixChat.AnonymousUser do
  use PhoenixChat.Web, :model

  alias PhoenixChat.Message

  # Since we provide the `id` for our AnonymousUser record, we will need to set
  # the primary key to not autogenerate it.
  @primary_key {:id, :binary_id, autogenerate: false}
  # We need to set `@foreign_key_type` below since it defaults to `:integer`.
  # We are using a UUID as `id` so we need to set type as `:binary_id`.
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
  This query returns users with the most recent message sent up to a given limit.
  """
  def recently_active_users(limit \\ 20) do
    from u in __MODULE__,
      left_join: m in Message, on: m.anonymous_user_id == u.id,
      limit: ^limit,
      distinct: u.id,
      order_by: [desc: u.inserted_at, desc: m.inserted_at]
  end

  # Set a fake name for our anonymous user every time we create one
  defp put_name(changeset) do
    name = (Faker.Color.fancy_name <> " " <> Faker.Company.buzzword()) |> String.downcase
    changeset
    |> put_change(:name, name)
  end

  # Set a fake avatar for our anonymous user every time we create one
  defp put_avatar(changeset) do
    changeset
    |> put_change(:avatar, Faker.Avatar.image_url(25, 25))
  end
end
