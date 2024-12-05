defmodule FinTech.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FinTech.Transactions` context.
  """

  @doc """
  Generate a cash_in.
  """
  def cash_in_fixture(attrs \\ %{}) do
    # Provide a default for transaction_type, e.g., "cash_in"
    transaction_type = attrs[:transaction_type] || "cash_in"

    {:ok, cash_in} =
      attrs
      |> Enum.into(%{
        # Add default values for other required fields here
        # For example:
        amount: Decimal.new(100),  # or a default amount
        user_id: nil,              # Placeholder; should be provided in attrs
        agent_id: nil,             # Placeholder; should be provided in attrs
        recipient_id: nil          # Placeholder; should be provided in attrs
      })
      |> FinTech.Transactions.create_cash_in(
        attrs.amount,
        attrs.agent_id,
        attrs.recipient_id,
        transaction_type
      )

    cash_in
  end
end
