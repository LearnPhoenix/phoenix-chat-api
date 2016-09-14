defmodule PhoenixChat.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :encrypted_password, :string
      add :username, :string

      timestamps()
    end

  end
end
