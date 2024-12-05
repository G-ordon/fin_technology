defmodule FinTech.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def up do
    create table(:transactions) do
      add :amount, :decimal
      add :sender_id, references(:users, on_delete: :delete_all)
      add :recipient_id, references(:users, on_delete: :delete_all)
      add :status, :string, default: "completed"

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:sender_id])
    create index(:transactions, [:recipient_id])
  end

  def down do
    drop table(:transactions)
  end
end
