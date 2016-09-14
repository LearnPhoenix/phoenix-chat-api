defmodule PhoenixChat.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string

      timestamps
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
