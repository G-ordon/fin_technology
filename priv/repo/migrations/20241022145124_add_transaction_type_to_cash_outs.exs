defmodule FinTech.Repo.Migrations.AddTransactionTypeToCashOuts do
  use Ecto.Migration

  def change do
    alter table(:cash_outs) do
      add :transaction_type, :string
    end
  end
end
