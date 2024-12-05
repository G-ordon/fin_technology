defmodule FinTech.Repo.Migrations.CreateRecipients do
  use Ecto.Migration

  def change do
    create table(:recipients) do
      add :name, :string
      add :location, :string
      add :phone_number, :string

      timestamps()
    end
  end
end
