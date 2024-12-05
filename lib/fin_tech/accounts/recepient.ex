defmodule FinTech.Accounts.Recipient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipients" do
    field :name, :string
    field :location, :string
    field :phone_number, :string

    timestamps()
  end

  def changeset(recipient, attrs) do
    recipient
    |> cast(attrs, [:name, :location, :phone_number])
    |> validate_required([:name, :location, :phone_number])
    |> validate_length(:phone_number, min: 10, max: 15)
    |> validate_format(:phone_number, ~r/^(07\d{8}|(\+254\d{9}))$/, message: "must start with 07 or +254 and be followed by valid digits")
    |> unique_constraint(:phone_number)
  end
end
