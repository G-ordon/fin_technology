defmodule FinTech.Repo.Migrations.EnforceNonNullPhoneNumber do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :phone_number, :string, null: false # Making phone_number non-nullable
    end
  end

  def down do
    alter table(:users) do
      modify :phone_number, :string, null: true # Allowing phone_number to be nullable again
    end
  end
end
