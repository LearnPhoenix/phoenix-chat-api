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
