defmodule PhoenixChat.Repo.Migrations.CreateAnonymousUsers do
  use Ecto.Migration

  def change do
    create table(:anonymous_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :avatar, :string

      timestamps
    end
  end
end
