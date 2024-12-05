defmodule MyApp.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :name, :string, null: false
      add :location, :string, null: false
      add :phone_number, :string, null: false

      timestamps()
    end
  end
end
