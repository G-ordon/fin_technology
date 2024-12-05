defmodule FinTech.Repo.Migrations.FixRecipientForeignKey do
  use Ecto.Migration

  def up do
    # Drop the existing recipient_id column
    alter table(:cash_ins) do
      remove :recipient_id
    end

    # Re-add the recipient_id column with the new foreign key reference
    alter table(:cash_ins) do
      add :recipient_id, references(:recipients, on_delete: :nothing)
    end
  end

  def down do
    # Drop the new recipient_id column
    alter table(:cash_ins) do
      remove :recipient_id
    end

    # Optionally, you can restore the previous state of the recipient_id if needed
    alter table(:cash_ins) do
      add :recipient_id, :integer # Adjust the type if it was different before
    end
  end
end
