defmodule FinTech.Repo.Migrations.UpdateWalletsUserIdForeignKey do
  use Ecto.Migration

  def up do
    # Drop the existing constraint if it exists to avoid duplicates
    drop_if_exists constraint(:wallets, :wallets_user_id_fkey)

    # Alter user_id with the new constraint
    alter table(:wallets) do
      modify :user_id, references(:users, on_delete: :delete_all)
    end

    # Drop the unique index if it exists and create it again
    drop_if_exists unique_index(:wallets, [:user_id])
    create unique_index(:wallets, [:user_id])
  end

  def down do
    # Drop the index and constraint created in up function
    drop_if_exists unique_index(:wallets, [:user_id])
    drop_if_exists constraint(:wallets, :wallets_user_id_fkey)

    # Restore original state of the user_id column
    alter table(:wallets) do
      modify :user_id, references(:users) # Removing on_delete for original state
    end
  end
end
