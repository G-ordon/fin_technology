defmodule FinTechWeb.USSDLive do
  use FinTechWeb, :live_view

  alias FinTech.Transactions
  alias FinTech.Accounts

  # Mount the LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, menu: "Welcome to FinTech!")}
  end

  # Handle incoming USSD requests
  def handle_info(%{type: :ussd_request, data: %{"sessionId" => _session_id, "phoneNumber" => phone_number, "text" => text}}, socket) do
    response = handle_ussd_request(text, phone_number)

    # Log the response for debugging
    IO.puts("Sending response to USSD: #{response}")

    # Here you would send the response back to the USSD gateway
    {:noreply, socket}
  end

  # Handle USSD text commands
  defp handle_ussd_request("", _phone_number) do
    "Welcome to FinTech! Please select an option:\n1. Check Balance\n2. Cash In\n3. Cash Out\n4. Transfer Funds\n5. Transaction History"
  end

  defp handle_ussd_request(option, phone_number) when option in ["1", "2", "3", "4", "5"] do
    case option do
      "1" -> get_balance(phone_number)
      "2" -> initiate_cash_in(phone_number)
      "3" -> initiate_cash_out(phone_number)
      "4" -> transfer_funds(phone_number)
      "5" -> transaction_history(phone_number)
    end
  end

  defp handle_ussd_request(_, _phone_number) do
    "Invalid option. Please try again."
  end

  # Function to get user balance
  defp get_balance(phone_number) do
    case Accounts.get_user_by_phone_number(phone_number) do
      nil -> "User not found."
      user -> "Your balance is: #{Transactions.get_balance(user.id)}"
    end
  end

  # Function to initiate cash-in
  defp initiate_cash_in(_phone_number) do
    "Initiate cash-in process."
  end

  # Function to initiate cash-out
  defp initiate_cash_out(_phone_number) do
    "Initiate cash-out process."
  end

  # Function to transfer funds
  defp transfer_funds(_phone_number) do
    "Initiate fund transfer."
  end

  # Function to get transaction history
  defp transaction_history(_phone_number) do
    "Fetching transaction history..."
  end

  # Render function for the LiveView
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @menu %></h1>
    </div>
    """
  end
end
