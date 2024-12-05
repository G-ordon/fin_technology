defmodule FinTech.Transactions.CashIn do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cash_ins" do
    field :transaction_type, :string
    field :amount, :decimal
    belongs_to :user, FinTech.Accounts.User       # This is the sender
    belongs_to :recipient, FinTech.Accounts.Recipient  # This should be the recipient
    belongs_to :agent, FinTech.Accounts.Agent

    timestamps()
  end

  @doc false
  def changeset(cash_in, attrs) do
    cash_in
    |> cast(attrs, [:amount, :user_id, :recipient_id, :agent_id, :transaction_type])
    |> validate_required([:amount, :user_id, :recipient_id, :agent_id, :transaction_type])
    |> foreign_key_constraint(:recipient_id, message: "recipient_id is invalid")
    |> foreign_key_constraint(:agent_id, message: "agent_id is invalid")
  end
  
end
