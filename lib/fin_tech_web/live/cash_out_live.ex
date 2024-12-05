defmodule FinTechWeb.CashOutLive do
  use FinTechWeb, :live_view

  alias FinTech.Wallet
  alias FinTech.Accounts
  alias FinTech.Transactions

  def mount(_params, session, socket) do
    token = Map.get(session, "user_token")

    case Accounts.get_user_by_session_token(token) do
      nil ->
        {:ok,
         put_flash(socket, :error, "You must be logged in to access cash-out.")
         |> redirect(to: "/users/log_in")}

      user ->
        cash_out_changeset = Transactions.change_cash_out()
        {:ok, assign(socket, current_user: user, cash_out_changeset: cash_out_changeset)}
    end
  end
  def handle_event("submit_cash_out", %{"cash_out" => cash_out_params}, socket) do
    user_id = socket.assigns.current_user.id
    amount = Decimal.new(cash_out_params["amount"])  # Convert amount to Decimal

    # Step 1: Get the user's wallet
    case Wallet.get_wallet_by_user(user_id) do
      nil ->
        {:noreply,
         put_flash(socket, :error, "Wallet not found.")}

      wallet ->
        # Step 2: Check if the user has enough balance
        if Decimal.compare(wallet.balance, amount) == :lt do
          {:noreply,
           put_flash(socket, :error, "Insufficient funds to cash out.")
           |> assign(agent_location: cash_out_params["agent_location"],
                     agent_name: cash_out_params["agent_name"],
                     agent_phone_number: cash_out_params["agent_phone_number"])}
        else
          # Step 3: Create the agent
          agent_params = %{
            name: cash_out_params["agent_name"],
            location: cash_out_params["agent_location"],
            phone_number: cash_out_params["agent_phone_number"]
          }

          # Create the agent
          case Accounts.create_agent(agent_params) do
            {:ok, agent} ->
              # Now create the cash-out with the new agent's ID and set transaction_type
              transaction_type = "Withdrawed"

              case Transactions.create_cash_out(user_id, amount, agent.id, transaction_type) do
                {:ok, _cash_out} ->
                  # Update the wallet balance
                  updated_balance = Decimal.sub(wallet.balance, amount)

                  case Wallet.update_balance(wallet.id, updated_balance) do
                    {:ok, _} ->
                      {:noreply,
                       put_flash(socket, :info, "Cash out successful!")
                       |> assign(agent_location: "",
                                 agent_name: "",
                                 agent_phone_number: "")}

                    {:error, changeset} ->
                      {:noreply,
                       put_flash(socket, :error, "Failed to update wallet balance: #{inspect(changeset.errors)}")}
                  end

                {:error, changeset} ->
                  {:noreply,
                   put_flash(socket, :error, "Failed to cash out: #{inspect(changeset.errors)}")}
              end

            {:error, changeset} ->
              {:noreply,
               put_flash(socket, :error, "Failed to create agent: #{inspect(changeset.errors)}")}
          end
        end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="cash-out-form">
      <h1>Cash Out</h1>
      <%= if @current_user do %>
        <form phx-submit="submit_cash_out">
          <%= for {field, _} <- @cash_out_changeset.errors do %>
            <div class="flash-message"><%= field %> is invalid</div>
          <% end %>

          <div>
            <label>Amount</label>
            <input type="number" name="cash_out[amount]" step="0.01" required />
          </div>
          <div>
            <label>Agent Name</label>
            <input type="text" name="cash_out[agent_name]" required />
          </div>
          <div>
            <label>Agent Location</label>
            <input type="text" name="cash_out[agent_location]" required />
          </div>
          <div>
            <label>Agent Phone Number</label>
            <input type="text" name="cash_out[agent_phone_number]" required />
          </div>
          <button type="submit">Cash Out</button>
        </form>
      <% else %>
        <p>You need to log in to perform a cash-out.</p>
      <% end %>

      <%= if @flash[:error] do %>
        <p class="flash-message"><%= @flash[:error] %></p>
      <% end %>
      <%= if @flash[:info] do %>
        <p class="flash-message"><%= @flash[:info] %></p>
      <% end %>
    </div>
    """
  end

  end
