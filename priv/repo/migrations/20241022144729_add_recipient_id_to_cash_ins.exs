defmodule FinTech.Repo.Migrations.AddRecipientIdToCashIns do
  use Ecto.Migration

  def change do
    alter table(:cash_ins) do
      add :recipient_id, references(:recipients, on_delete: :nothing)  # Reference the recipients table
    end

    create index(:cash_ins, [:recipient_id])  # Optional: Create an index for better performance on lookups
  end
end
