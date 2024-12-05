defmodule FinTech.Repo.Migrations.AddUserIdToKycs do
  use Ecto.Migration

  def change do
    alter table(:kycs) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:kycs, [:user_id])
  end
end
