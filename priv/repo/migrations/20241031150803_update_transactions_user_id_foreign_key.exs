defmodule FinTech.Repo.Migrations.UpdateTransactionsUserIdForeignKey do
  use Ecto.Migration

  def change do
    # Drop existing foreign key constraints if they exist
    execute "ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_sender_id_fkey"
    execute "ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_recipient_id_fkey"

    # Modify the sender_id and recipient_id foreign keys with `on_delete: :delete_all`
    alter table(:transactions) do
      modify :sender_id, references(:users, on_delete: :delete_all), null: false
      modify :recipient_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
