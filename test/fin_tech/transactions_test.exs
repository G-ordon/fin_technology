defmodule FinTech.TransactionsTest do
  use FinTech.DataCase  # This is for database-related tests.

  alias FinTech.Transactions
  alias FinTech.Accounts.User
  alias FinTech.Wallet

  describe "transfer_funds/3" do
    setup do
      # Create two users
      {:ok, sender} = FinTech.Repo.insert(%User{email: "sender@test.com", hashed_password: Bcrypt.hash_pwd_salt("password")})
      {:ok, recipient} = FinTech.Repo.insert(%User{email: "recipient@test.com", hashed_password: Bcrypt.hash_pwd_salt("password")})

      # Initialize wallet balances correctly
      {:ok, sender_wallet} = Wallet.create_wallet(sender.id, Decimal.new("100.0"))  # Ensure balance is 100.0
      {:ok, recipient_wallet} = Wallet.create_wallet(recipient.id, Decimal.new("50.0"))

      %{sender: sender, recipient: recipient, sender_wallet: sender_wallet, recipient_wallet: recipient_wallet}
    end


    test "successful transfer of funds", %{sender: sender, recipient: recipient} do
      amount = Decimal.new("30.0")

      assert {:ok, _transaction} = Transactions.transfer_funds(sender.id, recipient.id, amount)

      updated_sender_wallet = Wallet.get_wallet_by_user(sender.id)
      updated_recipient_wallet = Wallet.get_wallet_by_user(recipient.id)

      assert updated_sender_wallet.balance == Decimal.new("70.0")
      assert updated_recipient_wallet.balance == Decimal.new("80.0")
    end
    test "transfer fails with insufficient funds", %{sender: sender, recipient: recipient} do
      amount = Decimal.new("200.0")  # More than the sender's balance

      assert {:error, "Insufficient funds"} = Transactions.transfer_funds(sender.id, recipient.id, amount)
    end

    test "retrieves all transactions for a user", %{sender: sender, recipient: recipient} do
      sender_id = sender.id
      recipient_id = recipient.id
      amount = Decimal.new("30.0")

      # Perform the transfer
      {:ok, _transaction} = Transactions.transfer_funds(sender_id, recipient_id, amount)

      # Now fetch the transaction history
      transactions = Transactions.get_transaction_history(sender_id)

      IO.inspect(transactions, label: "Retrieved Transactions")

      # Assert that transactions were retrieved
      assert length(transactions) > 0
    end
  end


  describe "cash_ins" do
    alias FinTech.Transactions.CashIn

    import FinTech.TransactionsFixtures

    @invalid_attrs %{}

    test "list_cash_ins/0 returns all cash_ins" do
      cash_in = cash_in_fixture()
      assert Transactions.list_cash_ins() == [cash_in]
    end

    test "get_cash_in!/1 returns the cash_in with given id" do
      cash_in = cash_in_fixture()
      assert Transactions.get_cash_in!(cash_in.id) == cash_in
    end

    test "create_cash_in/1 with valid data creates a cash_in" do
      valid_attrs = %{}

      assert {:ok, %CashIn{} = cash_in} = Transactions.create_cash_in(valid_attrs)
    end

    test "create_cash_in/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_cash_in(@invalid_attrs)
    end

    test "update_cash_in/2 with valid data updates the cash_in" do
      cash_in = cash_in_fixture()
      update_attrs = %{}

      assert {:ok, %CashIn{} = cash_in} = Transactions.update_cash_in(cash_in, update_attrs)
    end

    test "update_cash_in/2 with invalid data returns error changeset" do
      cash_in = cash_in_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_cash_in(cash_in, @invalid_attrs)
      assert cash_in == Transactions.get_cash_in!(cash_in.id)
    end

    test "delete_cash_in/1 deletes the cash_in" do
      cash_in = cash_in_fixture()
      assert {:ok, %CashIn{}} = Transactions.delete_cash_in(cash_in)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_cash_in!(cash_in.id) end
    end

    test "change_cash_in/1 returns a cash_in changeset" do
      cash_in = cash_in_fixture()
      assert %Ecto.Changeset{} = Transactions.change_cash_in(cash_in)
    end
  end

  describe "cash_outs" do
    alias FinTech.Transactions.CashOut

    import FinTech.TransactionsFixtures

    @invalid_attrs %{}

    test "list_cash_outs/0 returns all cash_outs" do
      cash_out = cash_out_fixture()
      assert Transactions.list_cash_outs() == [cash_out]
    end

    test "get_cash_out!/1 returns the cash_out with given id" do
      cash_out = cash_out_fixture()
      assert Transactions.get_cash_out!(cash_out.id) == cash_out
    end

    test "create_cash_out/1 with valid data creates a cash_out" do
      valid_attrs = %{}

      assert {:ok, %CashOut{} = cash_out} = Transactions.create_cash_out(valid_attrs)
    end

    test "create_cash_out/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_cash_out(@invalid_attrs)
    end

    test "update_cash_out/2 with valid data updates the cash_out" do
      cash_out = cash_out_fixture()
      update_attrs = %{}

      assert {:ok, %CashOut{} = cash_out} = Transactions.update_cash_out(cash_out, update_attrs)
    end

    test "update_cash_out/2 with invalid data returns error changeset" do
      cash_out = cash_out_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_cash_out(cash_out, @invalid_attrs)
      assert cash_out == Transactions.get_cash_out!(cash_out.id)
    end

    test "delete_cash_out/1 deletes the cash_out" do
      cash_out = cash_out_fixture()
      assert {:ok, %CashOut{}} = Transactions.delete_cash_out(cash_out)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_cash_out!(cash_out.id) end
    end

    test "change_cash_out/1 returns a cash_out changeset" do
      cash_out = cash_out_fixture()
      assert %Ecto.Changeset{} = Transactions.change_cash_out(cash_out)
    end
  end
end
