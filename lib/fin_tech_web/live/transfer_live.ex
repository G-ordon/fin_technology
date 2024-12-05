defmodule FinTechWeb.TransferLive do
  use FinTechWeb, :live_view
  alias FinTech.Accounts
  alias FinTech.Wallet
  alias FinTech.Transactions
  alias Phoenix.PubSub

  @doc """
  Mounts the LiveView and assigns the necessary initial data.
  """
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:error, redirect(socket, to: "/")} # Redirect if user is not found
      user ->
        {:ok, assign(socket, current_user: user, recipient_email: "", amount: "", error: nil, success: nil, success_popup: false)}
    end
  end

  @doc """
  Renders the form for transferring funds.
  """
  def render(assigns) do
    ~H"""
    <div class="transfer-funds">
      <h1><strong>Transfer Funds</strong></h1>
         <br>
      <%= if @error do %>
        <p class="error-message"><%= @error %></p>
      <% end %>

      <form phx-submit="transfer" class="transfer-form">
        <div class="form-group">
          <label for="recipient_email">Recipient Email</label>
          <input type="email" name="recipient_email" id="recipient_email" value={@recipient_email} required class="form-input" />
        </div>
        <div class="form-group">
          <label for="amount">Amount</label>
          <input type="number" name="amount" id="amount" value={@amount} required step="0.01" class="form-input" />
        </div>
        <div class="form-group">
          <button type="submit" class="submit-button">Transfer</button>
        </div>
      </form>

      <div id="success-modal" class={"modal #{if @success_popup, do: "", else: "hidden"}"}>
        <div class="modal-content">
          <span class="close-button" phx-click="close_success_popup">&times;</span>
          <h2>Transfer Successful!</h2>
          <p>Your transfer has been completed successfully.</p>
        </div>
      </div>

      <style>
        .transfer-funds {
          max-width: 500px;
          margin: 0 auto;
          padding: 20px;
          border: 1px solid #ccc;
          border-radius: 8px;
          background-color: #f9f9f9;
        }

        .error-message {
          color: red;
          margin-bottom: 20px;
        }

        .transfer-form {
          display: flex;
          flex-direction: column;
        }

        .form-group {
          margin-bottom: 15px;
        }

        .form-input {
          width: 100%;
          padding: 10px;
          border: 1px solid #ccc;
          border-radius: 4px;
        }

        .submit-button {
          padding: 10px 15px;
          background-color: #28a745;
          color: white;
          border: none;
          border-radius: 4px;
          cursor: pointer;
        }

        .submit-button:hover {
          background-color: #218838;
        }

        .modal {
          display: block; /* Hidden by default */
          position: fixed; /* Stay in place */
          z-index: 1; /* Sit on top */
          left: 0;
          top: 0;
          width: 100%; /* Full width */
          height: 100%; /* Full height */
          overflow: auto; /* Enable scroll if needed */
          background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
        }

        .modal-content {
          background-color: #fefefe;
          margin: 15% auto; /* 15% from the top and centered */
          padding: 20px;
          border: 1px solid #888;
          width: 80%; /* Could be more or less, depending on screen size */
          border-radius: 8px;
        }

        .close-button {
          color: #aaa;
          float: right;
          font-size: 28px;
          font-weight: bold;
        }

        .close-button:hover,
        .close-button:focus {
          color: black;
          text-decoration: none;
          cursor: pointer;
        }

        .hidden {
          display: none;
        }
      </style>
    </div>
    """
  end

  @doc """
  Handles the transfer event.
  """
  def handle_event("transfer", %{"recipient_email" => recipient_email, "amount" => amount_str}, socket) do
    case Float.parse(amount_str) do
      {amount_float, ""} ->
        amount = Decimal.from_float(amount_float)
        sender = socket.assigns.current_user

        case Wallet.get_wallet_by_user(sender.id) do
          nil ->
            {:noreply, assign(socket, error: "Sender does not have a wallet", success: nil)}

          sender_wallet ->
            if Decimal.compare(sender_wallet.balance, amount) == :lt do
              {:noreply, assign(socket, error: "Insufficient funds", success: nil)}
            else
              case Accounts.get_user_by_email(recipient_email) do
                nil ->
                  # Create a new recipient if they don't exist
                  case Accounts.create_user(%{email: recipient_email, password: "default_password"}) do
                    {:ok, recipient} ->
                      # Create wallet for new recipient with initial balance of 0
                      case Wallet.create_wallet(recipient.id, 0) do
                        {:ok, _wallet} ->
                          execute_transfer(sender, recipient, amount, socket)

                        {:error, _message} ->
                          {:noreply, assign(socket, error: "Failed to create recipient's wallet", success: nil)}
                      end

                    {:error, _changeset} ->
                      {:noreply, assign(socket, error: "Failed to create recipient", success: nil)}
                  end

                recipient ->
                  # Ensure recipient has a wallet
                  case Wallet.get_wallet_by_user(recipient.id) do
                    nil ->
                      # Create wallet for recipient only if not exists
                      case Wallet.create_wallet(recipient.id, 0) do
                        {:ok, _wallet} -> :ok
                        {:error, _message} ->
                          {:noreply, assign(socket, error: "Failed to create recipient's wallet", success: nil)}
                      end
                    _ -> :ok # Recipient already has a wallet
                  end

                  execute_transfer(sender, recipient, amount, socket)
              end
            end
        end

      :error ->
        {:noreply, assign(socket, error: "Invalid amount format", success: nil)}
    end
  end

  def handle_event("close_success_popup", _params, socket) do
    {:noreply, assign(socket, success_popup: false)}
  end

  defp execute_transfer(sender, recipient, amount, socket) do
    # Step 5: Transfer Funds
    case Transactions.transfer_funds(sender.id, recipient.id, amount) do
      {:ok, transaction} ->
        # Broadcast the new transaction to the user's transaction history
        PubSub.broadcast(
          FinTech.PubSub,
          "transaction_updates:#{sender.id}",
          %{action: :new_transaction, transaction: transaction}
        )

        {:noreply, assign(socket, success: "Transfer successful", error: nil, success_popup: true, amount: "", recipient_email: "")}

      {:error, message} ->
        {:noreply, assign(socket, error: message, success: nil)}
    end
  end
end
