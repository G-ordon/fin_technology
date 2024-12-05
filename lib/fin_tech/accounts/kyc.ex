defmodule FinTech.Accounts.KYC do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kycs" do
    field :full_name, :string
    field :address, :string
    field :document_type, :string
    field :document_number, :string
    field :user_id, :id  # Add this line to include user_id in the schema

    timestamps()
  end

  @doc false
  def changeset(kyc, attrs) do
    kyc
    |> cast(attrs, [:full_name, :address, :document_type, :document_number, :user_id])  # Include user_id here
    |> validate_required([:full_name, :address, :document_type, :document_number, :user_id])  # Include user_id in required fields
  end
end
