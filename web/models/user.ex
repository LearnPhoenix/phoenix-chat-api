defmodule PhoenixChat.User do
  use PhoenixChat.Web, :model

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :username, :string

    timestamps
  end

  @required_fields ~w(email encrypted_password username)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:username, min: 1, max: 20)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> update_change(:username, &String.downcase/1)
    |> unique_constraint(:username)
  end
end
