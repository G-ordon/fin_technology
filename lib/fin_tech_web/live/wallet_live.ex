defmodule FinTechWeb.WalletLive do
  use FinTechWeb, :live_view
  alias FinTech.Wallet
  alias FinTech.Accounts

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    if user do
      wallet = Wallet.get_wallet_by_user(user.id)

      if wallet do
        balance = wallet.balance
        {:ok, assign(socket, balance: balance, user_token: user_token, current_user: user)}
      else
        {:ok, assign(socket, balance: 0, user_token: user_token, current_user: user)}  # Default to 0 if wallet not found
      end
    else
      {:ok, redirect(socket, to: "/")}  # Redirect if not authenticated
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto mt-5 p-5 border border-gray-300 rounded-lg shadow-lg">
      <h1 class="text-2xl font-bold text-center mb-4">Your Wallet Balance</h1>
      <p class="text-lg text-center mb-4">
        Balance: <strong class="text-green-600 text-2xl"><%= @balance %></strong>
      </p>
      <div class="flex justify-center mb-4">
        <button
          class="bg-blue-500 text-white px-4 py-2 rounded-lg shadow hover:bg-blue-600 transition duration-300"
          phx-click="refresh_balance">
          Refresh Balance
        </button>
      </div>
      <div class="text-center">
        <p class="text-sm text-gray-500">Last updated: <span class="font-medium"><%= Timex.format!(DateTime.utc_now(), "{ISO:Extended}") %></span></p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh_balance", _params, socket) do
    user = Accounts.get_user_by_session_token(socket.assigns.user_token)

    if user do
      wallet = Wallet.get_wallet_by_user(user.id)
      new_balance = if wallet, do: wallet.balance, else: 0
      {:noreply, assign(socket, balance: new_balance)}
    else
      {:noreply, redirect(socket, to: "/")}  # Redirect if not authenticated
    end
  end
end
