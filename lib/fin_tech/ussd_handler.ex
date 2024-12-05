defmodule FinTech.USSDHandler do
  alias FinTech.Transactions
  alias FinTech.Accounts
  alias FinTech.Repo
  alias FinTech.Wallet

  @ussd_menu """
  CON Welcome to FinTech! Choose an option:
  1. Check Balance
  2. Cash In
  3. Cash Out
  4. Transfer
  5. Transaction History
  """

  def handle_request(text, phone_number) do
    case String.split(text, "*") do
      ["" | _] ->
        send_response(@ussd_menu)

      ["1"] ->
        handle_check_balance(phone_number)

      ["2"] ->
        send_response("CON Enter the amount to cash in:")

      ["2", amount] ->
        handle_cash_in_amount(phone_number, amount)

      ["3"] ->
        send_response("CON Enter the amount to cash out:")

      ["3", amount] ->
        handle_cash_out_amount(phone_number, amount)

      ["4"] ->
        send_response("CON Enter recipient's phone number:")

      ["4", recipient] ->
        handle_transfer_funds(phone_number, recipient)

      ["4", recipient, amount] ->
        handle_transfer_amount(phone_number, recipient, amount)

      ["5"] ->
        handle_transaction_history(phone_number)

      _ ->
        send_response("END Invalid option. Please try again.")
    end
  end

  defp handle_check_balance(phone_number) do
    case Accounts.get_user_by_phone_number(phone_number) do
      nil ->
        send_response("END User not found. Please register to use this service.")

      user ->
        case Accounts.get_balance(user.id) do
          {:ok, balance} ->
            send_response("END Your balance is $#{balance}.")

          {:error, _reason} ->
            send_response("END Error retrieving balance. Please try again.")
        end
    end
  end

  defp handle_cash_in_amount(phone_number, amount) do
    case Integer.parse(amount) do
      {amount_int, ""} when amount_int > 0 ->
        IO.inspect("Initiating cash-in for #{phone_number} with amount: #{amount_int}")

        case Accounts.get_user_by_phone_number(phone_number) do
          nil ->
            send_response("END User not found. Please register to use this service.")

          user ->
            agent_attrs = %{
              name: "Agent",
              location: "Location",
              phone_number: "0700897878"
            }
            recipient_attrs = %{
              name: "Recipient",
              location: "Locations",
              phone_number: phone_number
            }
            transaction_type = "cash_in"

            case Transactions.create_cash_in(user.id, amount_int, agent_attrs, recipient_attrs, transaction_type) do
              {:ok, _transaction} ->
                IO.inspect("Cash-in successful for #{phone_number} with amount: #{amount_int}")
                send_response("END You have successfully cashed in $#{amount_int}. Your new balance will be updated shortly.")

              {:error, _reason} ->
                IO.inspect("Cash-in failed for #{phone_number}")
                send_response("END Cash-in failed. Please try again later.")
            end
        end

      _ ->
        send_response("END Invalid amount entered. Please enter a valid number.")
    end
  end

  defp handle_cash_out_amount(phone_number, amount) do
    case Integer.parse(amount) do
      {amount_int, ""} when amount_int > 0 ->
        IO.inspect("Initiating cash-out for #{phone_number} with amount: #{amount_int}", label: "Debug")

        case Accounts.get_user_by_phone_number(phone_number) do
          nil ->
            send_response("END User not found. Please register to use this service.")

          user ->
            agent_attrs = %{
              name: "Agent",
              location: "Mbita",
              phone_number: "0756786567"
            }
            transaction_type = "cash_out"

            # Create the agent record
            agent = %FinTech.Accounts.Agent{}
            case Repo.insert(agent |> FinTech.Accounts.Agent.changeset(agent_attrs)) do
              {:ok, agent_record} ->
                case Transactions.create_cash_out(user.id, amount_int, agent_record.id, transaction_type) do
                  {:ok, _transaction} ->
                    IO.inspect("Cash-out successful for #{phone_number} with amount: #{amount_int}", label: "Success")

                    case Wallet.get_wallet_by_user(user.id) do
                      nil ->
                        send_response("END Cash-out successful, but no wallet found. Please contact support.")

                      user_wallet ->
                        cash_out_amount_decimal = Decimal.new(amount_int)
                        updated_balance = Decimal.sub(user_wallet.balance, cash_out_amount_decimal)

                        case Wallet.update_balance(user_wallet.id, updated_balance) do
                          {:ok, _updated_wallet} ->
                            send_response("END You have successfully cashed out $#{amount_int}. Your new balance is updated.")

                          {:error, _reason} ->
                            send_response("END Cash-out successful, but failed to update balance. Please check with support.")
                        end
                    end

                  {:error, "Insufficient funds"} ->
                    send_response("END Insufficient funds for this cash-out request.")

                  {:error, reason} ->
                    IO.inspect(reason, label: "Cash-out Error")
                    send_response("END Cash-out failed. Please try again later.")
                end

              {:error, changeset} ->
                IO.inspect(changeset, label: "Agent Creation Error")
                send_response("END Failed to initiate cash-out due to agent creation issue. Please try again later.")
            end
        end

      _ ->
        send_response("END Invalid amount entered. Please enter a valid number.")
    end
  end

  defp handle_transfer_funds(_phone_number, recipient) do
    # Prompt for the amount to transfer to the recipient
    send_response("CON Enter the amount to transfer to #{recipient}:")
  end

  defp handle_transfer_amount(phone_number, recipient, amount) do
    recipient = normalize_phone_number(recipient)

    case Integer.parse(amount) do
      {amount_int, ""} when amount_int > 0 ->
        case Accounts.get_user_by_phone_number(phone_number) do
          nil ->
            send_response("END Your account not found. Please register to use this service.")

          sender ->
            case Accounts.get_user_by_phone_number(recipient) do
              nil ->
                send_response("END Recipient not found. Please check the phone number.")

              recipient_user ->
                # Proceed with the transfer
                case Transactions.transfer_funds(sender.id, recipient_user.id, amount_int) do
                  {:ok, _transaction} ->
                    send_response("END Transfer of $#{amount_int} to #{recipient} successful.")

                  {:error, _reason} ->
                    send_response("END Transfer failed. Please try again.")
                end
            end
        end

      _ ->
        send_response("END Invalid amount entered. Please enter a valid number.")
    end
  end

  defp normalize_phone_number(phone_number) do
    # Assuming you want to format numbers as +254...
    if String.starts_with?(phone_number, "0") do
      "+254" <> String.trim_leading(phone_number, "0")
    else
      phone_number
    end
  end

  defp handle_transaction_history(phone_number) do
    cash_outs = Transactions.get_cash_outs_by_user(phone_number)
    cash_ins = Transactions.get_cash_ins_by_recipient(phone_number)
    transfers = Transactions.get_transfers_by_user(phone_number)

    # Combine the transaction lists
    transactions = cash_outs ++ cash_ins ++ transfers

    # Format the transaction history
    formatted_history =
      if transactions == [] do
        "No transaction history available."
      else
        transactions
        |> Enum.map(&format_transaction(&1))
        |> Enum.join("\n")
      end

    send_response("END Transaction History:\n#{formatted_history}")
  end

  defp format_transaction(transaction) do
    case transaction do
      %{transaction_type: "cash_in", amount: amount, inserted_at: date} ->
        "Cash In: Ksh #{amount} on #{format_date(date)}"
      %{transaction_type: "cash_out", amount: amount, inserted_at: date} ->
        "Cash Out: Ksh #{amount} on #{format_date(date)}"
      %{transaction_type: "transfer", amount: amount, recipient_id: recipient, inserted_at: date} ->
        "Transfer: Ksh #{amount} to #{recipient} on #{format_date(date)}"
    end
  end

  defp format_date(inserted_at) do
    # Format the date as needed, e.g., "YYYY-MM-DD"
    Timex.format!(inserted_at, "{YYYY}-{0M}-{0D}")
  end

  defp send_response(message) do
    IO.puts(message)
    message
  end
end
