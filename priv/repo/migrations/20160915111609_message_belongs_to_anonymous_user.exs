defmodule PhoenixChat.Repo.Migrations.MessageBelongsToAnonymousUser do
  use Ecto.Migration

  def up do
    alter table(:messages) do
      # We need to set `type` as `uuid` so it does not default to `integer`.
      add :anonymous_user_id, references(:anonymous_users, on_delete: :nilify_all, type: :uuid)
      remove :from
    end
  end

  def down do
    alter table(:messages) do
      remove :anonymous_user_id
      add :from, :string
    end
  end
end
