defmodule FinTech.Repo.Migrations.CreateCashIns do
  use Ecto.Migration

  def change do
    create table(:cash_ins) do
      add :amount, :decimal, precision: 10, scale: 2
      add :user_id, references(:users, on_delete: :delete_all)
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create index(:cash_ins, [:user_id])
    create index(:cash_ins, [:agent_id])
  end
end
