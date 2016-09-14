defmodule PhoenixChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :string
      add :from, :string
      add :room, :string
      add :timestamp, :datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:messages, [:user_id])

  end
end
