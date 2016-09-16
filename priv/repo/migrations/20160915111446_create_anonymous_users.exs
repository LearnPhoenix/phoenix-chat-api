defmodule PhoenixChat.Repo.Migrations.CreateAnonymousUsers do
  use Ecto.Migration

  def change do
    # We want to use a `uuid` as primary key so we need to set `primary_key: false`.
    create table(:anonymous_users, primary_key: false) do
      # We add the `:id` column manually with a type of `uuid` and set
      # it as `primary_key`.
      add :id, :uuid, primary_key: true
      add :name, :string
      add :avatar, :string
      add :public_key, :string
      add :last_viewed_by_admin_at, :datetime

      timestamps
    end
  end
end
