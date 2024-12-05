defmodule FinTechWeb.TransactionHistoryLive do
  use FinTechWeb, :live_view

  alias FinTech.Transactions
  alias FinTech.Accounts
  alias Phoenix.PubSub

  def mount(_params, session, socket) do
    token = Map.get(session, "user_token")

    case Accounts.get_user_by_session_token(token) do
      nil ->
        {:ok,
         put_flash(socket, :error, "You must be logged in to access transaction history.")
         |> redirect(to: "/users/log_in")}

      user ->
        transaction_history = Transactions.get_transaction_history(user.id)

        # Subscribe to transaction updates for this user
        PubSub.subscribe(FinTech.PubSub, "transaction_updates:#{user.id}")

        {:ok, assign(socket, current_user: user, transaction_history: transaction_history)}
    end
  end

  def handle_info(%{action: :new_transaction, transaction: transaction}, socket) do
    # Add the new transaction to the top of the list
    transaction_history = [transaction | socket.assigns.transaction_history]
    {:noreply, assign(socket, transaction_history: transaction_history)}
  end

  def render(assigns) do
    ~H"""
    <h1><strong>Transaction History</strong></h1>
    <br>
    <%= if @transaction_history && length(@transaction_history) > 0 do %>
      <table>
        <thead>
          <tr>
            <th>Amount</th>
            <th>Type</th>
            <th>Date</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <%= for transaction <- @transaction_history do %>
            <tr>
              <td><%= transaction.amount %></td>
              <td><%= Map.get(transaction, :transaction_type, "send") %></td>
              <td><%= transaction.inserted_at %></td>
              <td class={"status #{if(Map.get(transaction, :status, "Completed") == "Completed", do: "success", else: if(Map.get(transaction, :status, "Completed") == "Failed", do: "error", else: "warning"))}"}>
                <%= Map.get(transaction, :status, "Completed") %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <p class="no-transactions">No transactions found.</p>
    <% end %>
    """
  end

end
