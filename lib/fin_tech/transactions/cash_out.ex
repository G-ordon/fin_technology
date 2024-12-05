defmodule FinTech.Transactions.CashOut do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cash_outs" do
    field :amount, :decimal
    field :transaction_type, :string  # Add this line
    belongs_to :user, FinTech.Accounts.User
    belongs_to :agent, FinTech.Accounts.Agent

    timestamps()
  end

  @doc false
  def changeset(cash_out, attrs) do
    cash_out
    |> cast(attrs, [:amount, :transaction_type, :user_id, :agent_id])  # Add :transaction_type here
    |> validate_required([:amount, :transaction_type, :user_id, :agent_id])  # Add :transaction_type here
  end
end
