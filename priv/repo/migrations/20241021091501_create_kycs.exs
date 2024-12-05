defmodule FinTech.Repo.Migrations.CreateKycs do
  use Ecto.Migration

  def change do
    create table(:kycs) do
      add :full_name, :string
      add :address, :string
      add :document_type, :string
      add :document_number, :string

      timestamps()
    end
  end
end
