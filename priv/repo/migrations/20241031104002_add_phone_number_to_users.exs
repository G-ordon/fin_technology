defmodule FinTech.Repo.Migrations.AddPhoneNumberToUsers do
  use Ecto.Migration

  def change do
  alter table(:users) do
    add :phone_number, :string, null: true
  end

  create unique_index(:users, [:phone_number])
  end
end
