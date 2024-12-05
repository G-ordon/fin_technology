defmodule FinTech.Transactions do
  alias FinTech.Repo
  alias FinTech.Transaction
  alias FinTech.Transactions.{CashIn, CashOut}
  alias FinTech.Wallet
  alias Phoenix.PubSub



  import Ecto.Query

  @doc """
  Transfers money from one user to another.
  """
  def transfer_funds(sender_id, recipient_id, amount) do
    amount_decimal = Decimal.new(amount)  # Convert the amount to Decimal

    Repo.transaction(fn ->
      with {:ok, sender_wallet} <- get_wallet(sender_id),
           {:ok, recipient_wallet} <- get_wallet(recipient_id) do

        # Ensure sender has enough balance
        case Decimal.compare(sender_wallet.balance, amount_decimal) do
          :lt ->
            Repo.rollback("Insufficient funds")  # Rollback if insufficient funds

          _ ->
            # Deduct from sender's wallet
            sender_balance_updated = Decimal.sub(sender_wallet.balance, amount_decimal)

            case Wallet.update_balance(sender_wallet.id, sender_balance_updated) do
              {:ok, _} ->
                # Add to recipient's wallet
                recipient_balance_updated = Decimal.add(recipient_wallet.balance, amount_decimal)

                case Wallet.update_balance(recipient_wallet.id, recipient_balance_updated) do
                  {:ok, _} ->
                    # Create transaction record for the sender
                    transaction = %Transaction{}
                    |> Transaction.changeset(%{
                      amount: amount_decimal,
                      sender_id: sender_id,
                      recipient_id: recipient_id,
                      transaction_type: "transfer"  # Assuming you want to mark it as a transfer
                    })
                    |> Repo.insert()

                    case transaction do
                      {:ok, transaction} ->
                        # Broadcast the new transaction to both sender and recipient
                        PubSub.broadcast(FinTech.PubSub, "transaction_updates:#{sender_id}", %{action: :new_transaction, transaction: transaction})
                        PubSub.broadcast(FinTech.PubSub, "transaction_updates:#{recipient_id}", %{action: :new_transaction, transaction: transaction})
                        {:ok, transaction}

                      {:error, changeset} ->
                        Repo.rollback("Failed to create transaction: #{inspect(changeset.errors)}")
                    end

                  {:error, changeset} ->
                    Repo.rollback("Failed to update recipient balance: #{inspect(changeset.errors)}")
                end

              {:error, changeset} ->
                Repo.rollback("Failed to update sender balance: #{inspect(changeset.errors)}")
            end
        end
      else
        {:error, message} ->
          Repo.rollback(message)  # Rollback on user not found
      end
    end)
  end

  # Helper function to get the wallet
  defp get_wallet(user_id) do
    case Wallet.get_wallet_by_user(user_id) do
      nil ->
        {:error, "User not found"}
      wallet ->
        {:ok, wallet}
    end
  end

  @doc """
  Updates the status of a transaction.
  """
  def update_transaction_status(transaction_id, new_status) do
    transaction = Repo.get(Transaction, transaction_id)

    case transaction do
      nil ->
        {:error, "Transaction not found"}

      _ ->
        transaction
        |> Transaction.changeset(%{status: new_status})
        |> Repo.update()
    end
  end

  def get_balance(user_id) do
    case Repo.get(Wallet, user_id) do
      nil -> 0  # Return 0 if no wallet is found
      wallet -> wallet.balance  # Assuming your wallet schema has a balance field
    end
  end
@doc """
Retrieves all transactions for a given user (as sender or recipient).
"""
def get_transaction_history(user_id) do
  # Fetch all cash out transactions where the user is the sender
  cash_outs = Repo.all(
    from co in CashOut,
    where: co.user_id == ^user_id,  # User as the sender
    order_by: [desc: co.inserted_at],
    preload: [:agent]  # Preload agent info
  )

  # Fetch all cash in transactions where the user is the recipient
  cash_ins = Repo.all(
    from ci in CashIn,
    where: ci.recipient_id == ^user_id,  # User as the recipient
    order_by: [desc: ci.inserted_at],
    preload: [:user]  # Preload user info for the sender
  )

  # Fetch all transfer transactions where the user is either sender or recipient
  transfers = Repo.all(
    from t in Transaction,
    where: t.sender_id == ^user_id or t.recipient_id == ^user_id,
    order_by: [desc: t.inserted_at]
  )

  # Combine all transaction lists
  transactions = cash_outs ++ cash_ins ++ transfers

  # Sort transactions by inserted_at in descending order
  Enum.sort(transactions, &(&1.inserted_at >= &2.inserted_at))
end

  # Cashing functions
  # Change cash-in with changeset
  @spec change_cash_in(
    :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
  ) :: Ecto.Changeset.t()
  def change_cash_in(attrs \\ %{}) do
    %CashIn{}
    |> CashIn.changeset(attrs)
  end

  # Create cash-in transaction
  def create_cash_in(user_id, amount, agent_attrs, recipient_attrs, transaction_type) do
    Repo.transaction(fn ->
      # Fetch the user's wallet
      user_wallet = Wallet.get_wallet_by_user(user_id)

      # Ensure the wallet exists before proceeding
      if user_wallet do
        # Convert the cash-in amount to Decimal
        cash_in_amount_decimal = Decimal.new(amount)

        # Calculate the new balance
        updated_balance = Decimal.add(user_wallet.balance, cash_in_amount_decimal)

        # Create the agent record
        IO.inspect(agent_attrs, label: "Agent Attributes")  # Debugging line
        {:ok, agent_record} =
          %FinTech.Accounts.Agent{}
          |> FinTech.Accounts.Agent.changeset(agent_attrs)
          |> Repo.insert()

        # Create the recipient record
        IO.inspect(recipient_attrs, label: "Recipient Attributes")  # Debugging line
        {:ok, recipient_record} =
          %FinTech.Accounts.Recipient{}
          |> FinTech.Accounts.Recipient.changeset(recipient_attrs)
          |> Repo.insert()

        # Update the user's wallet balance
        case Wallet.update_balance(user_wallet.id, updated_balance) do
          {:ok, _updated_wallet} ->
            # Now create the cash-in record with the new agent_id and recipient_id
            cash_in_changeset = %CashIn{}
            |> CashIn.changeset(%{
              amount: cash_in_amount_decimal,
              user_id: user_id,
              agent_id: agent_record.id,
              recipient_id: recipient_record.id,
              transaction_type: transaction_type
            })

            # Insert the cash-in transaction
            case Repo.insert(cash_in_changeset) do
              {:ok, transaction} ->
                PubSub.broadcast(FinTech.PubSub, "transaction_updates:#{user_id}", %{action: :new_transaction, transaction: transaction})
                {:ok, transaction}

              {:error, changeset} ->
                IO.inspect(changeset, label: "Cash-in Transaction Error")  # Debugging line
                Repo.rollback(changeset)  # Rollback if there's an error
            end

          {:error, _reason} ->
            IO.inspect("Failed to update wallet balance", label: "Wallet Update Error")  # Debugging line
            Repo.rollback("Wallet update failed")
        end
      else
        IO.inspect("Wallet not found for user: #{user_id}", label: "Wallet Check")  # Debugging line
        {:error, "Wallet not found."}
      end
    end)
  end

  # Changeset for cash out
  def change_cash_out(attrs \\ %{}) do
    %CashOut{}
    |> CashOut.changeset(attrs)
  end

  # Create cash out function that includes transaction_type
  def create_cash_out(user_id, amount, agent_id, transaction_type) do
    cash_out_changeset = %CashOut{}
    |> CashOut.changeset(%{amount: amount, user_id: user_id, agent_id: agent_id, transaction_type: transaction_type})

    case Repo.insert(cash_out_changeset) do
      {:ok, transaction} ->
        # Broadcast the new cash out transaction
        PubSub.broadcast(FinTech.PubSub, "transaction_updates:#{user_id}", %{action: :new_transaction, transaction: transaction})
        {:ok, transaction}
      {:error, changeset} ->
        {:error, changeset}
    end
  end
  def get_cash_outs_by_user(phone_number) do
    Repo.all(
      from t in Transaction,
        join: u in assoc(t, :sender),
        where: u.phone_number == ^phone_number and t.status == "completed",
        select: t
    )
  end

  def get_cash_ins_by_recipient(phone_number) do
    Repo.all(
      from t in Transaction,
        join: u in assoc(t, :recipient),
        where: u.phone_number == ^phone_number and t.status == "completed",
        select: t
    )
  end

  def get_transfers_by_user(phone_number) do
    Repo.all(
      from t in Transaction,
        join: sender in assoc(t, :sender),
        join: recipient in assoc(t, :recipient),
        where: (sender.phone_number == ^phone_number or recipient.phone_number == ^phone_number),
        select: t
    )
  end

end
