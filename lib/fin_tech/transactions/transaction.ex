defmodule FinTech.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :decimal
    field :status, :string, default: "pending"
    belongs_to :sender, FinTech.Accounts.User
    belongs_to :recipient, FinTech.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :sender_id, :recipient_id, :status])
    |> validate_required([:amount, :sender_id, :recipient_id])
    |> validate_number(:amount, greater_than: 0)
  end
end
