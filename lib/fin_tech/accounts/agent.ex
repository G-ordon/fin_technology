defmodule FinTech.Accounts.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agents" do
    field :name, :string
    field :location, :string
    field :phone_number, :string

    # This will automatically include an :id field of type integer as the primary key
    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :location, :phone_number])
    |> validate_required([:name, :location, :phone_number])
    |> validate_length(:phone_number, min: 10, max: 15)
    |> validate_format(:phone_number, ~r/^(07\d{8}|(\+254\d{9}))$/, message: "must start with 07 or +254 and be followed by valid digits")
    |> unique_constraint(:phone_number)
  end
end
