defmodule FinTechWeb.CashInLive do
  use FinTechWeb, :live_view

  alias FinTech.Accounts
  alias FinTech.Transactions
  alias FinTech.Wallet

  def mount(_params, session, socket) do
    token = Map.get(session, "user_token")
    case Accounts.get_user_by_session_token(token) do
      nil ->
        {:ok, put_flash(socket, :error, "You must be logged in to access cash-in.") |> redirect(to: "/users/log_in")}

      user ->
        cash_in_changeset = Transactions.change_cash_in()
        # Initialize cash_in_success
        {:ok, assign(socket, current_user: user, cash_in_changeset: cash_in_changeset, cash_in_success: false)}
    end
  end


  def handle_event("submit_cash_in", %{"cash_in" => cash_in_params}, socket) do
    IO.inspect(cash_in_params, label: "Initial Cash-in Params")  # Debugging line to check params

    # Check if cash_in_params has required fields
    required_fields = [
      "agent_name",
      "agent_location",
      "agent_phone_number",
      "recipient_name",
      "recipient_location",
      "recipient_phone_number",
      "amount"
    ]

    missing_fields = Enum.filter(required_fields, fn field ->
      cash_in_params[field] == "" || cash_in_params[field] == nil
    end)

    # Return early if there are missing fields
    if Enum.empty?(missing_fields) do
      # Continue processing
      # Extract agent and recipient details from the cash_in_params
      agent_params = %{
        name: cash_in_params["agent_name"],
        location: cash_in_params["agent_location"],
        phone_number: cash_in_params["agent_phone_number"]
      }

      recipient_attrs = %{
        name: cash_in_params["recipient_name"],
        location: cash_in_params["recipient_location"],
        phone_number: cash_in_params["recipient_phone_number"]
      }

      # Create the agent
      case Accounts.create_agent(agent_params) do
        {:ok, agent} ->
          IO.inspect(agent.id, label: "Agent ID")

          # Create the recipient
          case Accounts.create_recipient(recipient_attrs) do
            {:ok, recipient} ->
              IO.inspect(recipient.id, label: "Recipient ID")

              # Now create the cash-in with the new agent's ID and recipient's ID
              cash_in_params =
                cash_in_params
                |> Map.put("agent_id", agent.id)
                |> Map.put("recipient_id", recipient.id)

              IO.inspect(cash_in_params, label: "Cash-in Params After Adding IDs")

              # Ensure amount is a valid Decimal
              amount = Decimal.new(cash_in_params["amount"])

              case Transactions.create_cash_in(
                     socket.assigns.current_user.id,
                     amount,
                     agent_params,
                     recipient_attrs,
                     "Deposit"
                   ) do
                {:ok, _cash_in} ->
                  # Update the user's wallet balance after successful cash-in
                  user_wallet = Wallet.get_wallet_by_user(socket.assigns.current_user.id)

                  case user_wallet do
                    nil ->
                      # If the wallet does not exist, create one with the cash-in amount
                      Wallet.create_wallet(socket.assigns.current_user.id, amount)

                    _wallet ->
                      # Update the wallet balance
                      new_balance = Decimal.add(user_wallet.balance, amount)
                      Wallet.update_balance(user_wallet.id, new_balance)
                  end

                  {:noreply,
                   socket
                   |> put_flash(:info, "Cash in successful!")
                   |> assign(:cash_in_success, true)}

                {:error, changeset} ->
                  IO.inspect(changeset, label: "Cash-in Changeset Errors")
                  # Handle errors in creating the cash-in
                  error_messages =
                    changeset.errors
                    |> Enum.map(fn {field, {message, _opts}} -> "#{field} #{message}" end)
                    |> Enum.join(", ")

                  {:noreply,
                   socket
                   |> put_flash(:error, "Failed to cash in: #{error_messages}")
                   |> assign(cash_in_changeset: changeset)}
              end

            {:error, changeset} ->
              # Handle recipient creation error (return the changeset with errors)
              error_messages =
                changeset.errors
                |> Enum.map(fn {field, {message, _opts}} -> "#{field} #{message}" end)
                |> Enum.join(", ")

              {:noreply,
               socket
               |> put_flash(:error, "Failed to create recipient: #{error_messages}")
               |> assign(cash_in_changeset: changeset)}
          end

        {:error, changeset} ->
          # Handle agent creation error (return the changeset with errors)
          error_messages =
            changeset.errors
            |> Enum.map(fn {field, {message, _opts}} -> "#{field} #{message}" end)
            |> Enum.join(", ")

          {:noreply,
           socket
           |> put_flash(:error, "Failed to create agent: #{error_messages}")
           |> assign(cash_in_changeset: changeset)}
      end
    else
      # Flash an error message if there are missing fields
      socket =
        socket
        |> put_flash(:error, "Missing fields: #{Enum.join(missing_fields, ", ")}")

      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="cash-in-container">
      <h2>Cash In</h2>
      <%= if @current_user do %>
        <form phx-submit="submit_cash_in">
          <%= for {field, _} <- @cash_in_changeset.errors do %>
            <div class="error-message"><%= field %> is invalid</div>
          <% end %>

          <div>
            <label>Amount</label>
            <input type="number" name="cash_in[amount]" step="0.01" required />
          </div>
          <div>
            <label>Recipient Name</label>
            <input type="text" name="cash_in[recipient_name]" required />
          </div>
          <div>
            <label>Recipient Location</label>
            <input type="text" name="cash_in[recipient_location]" required />
          </div>
          <div>
            <label>Recipient Phone Number</label>
            <input type="text" name="cash_in[recipient_phone_number]" placeholder="must begin with 07 or +254" required/>
            </div>
          <div>
            <label>Agent Name</label>
            <input type="text" name="cash_in[agent_name]" required />
          </div>
          <div>
            <label>Agent Location</label>
            <input type="text" name="cash_in[agent_location]" required />
          </div>
          <div>
            <label>Agent Phone Number</label>
            <input type="text" name="cash_in[agent_phone_number]" placeholder="must begin with 07 or +254" required />
          </div>
          <button type="submit">Submit Cash In</button>
          <div class="success-message"><%= if @cash_in_success, do: "Cash in successful!" %></div>
        </form>
      <% else %>
        <p>You need to log in to cash in.</p>
      <% end %>
    </div>
    """
  end
end
