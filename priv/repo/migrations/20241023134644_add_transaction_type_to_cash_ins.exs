defmodule FinTech.Repo.Migrations.AddTransactionTypeToCashIns do
  use Ecto.Migration

  def change do
    alter table(:cash_ins) do
      add :transaction_type, :string
    end
  end
end
