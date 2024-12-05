defmodule FinTech.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias FinTech.Repo
  alias FinTech.Wallet

  schema "wallets" do
    field :balance, :decimal, default: 0.0
    belongs_to :user, FinTech.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:balance, :user_id])
    |> validate_required([:balance, :user_id])
  end

  @doc """
  Creates a wallet for a user with an optional initial balance.
  Ensures that a user can only have one wallet.
  """
  def create_wallet(user_id, initial_balance \\ 0.0) do
    case Repo.get_by(__MODULE__, user_id: user_id) do
      nil ->
        %Wallet{user_id: user_id, balance: Decimal.new(initial_balance)}
        |> changeset(%{user_id: user_id, balance: Decimal.new(initial_balance)})
        |> Repo.insert()

      _wallet ->
        {:error, "Wallet already exists for this user."}
    end
  end

  @doc """
  Retrieves the first wallet for a given user.
  If multiple wallets exist, only the first one is returned.
  """
  def get_wallet_by_user(user_id) do
    Repo.one(from w in __MODULE__, where: w.user_id == ^user_id)
  end

  @doc """
  Updates the balance of a wallet by a specified amount.
  """
  def update_balance(wallet_id, new_balance) do
    new_balance_decimal = Decimal.new(new_balance)

    Repo.transaction(fn ->
      wallet = Repo.get!(Wallet, wallet_id)

      case wallet
           |> Ecto.Changeset.change(balance: new_balance_decimal)
           |> Repo.update() do
        {:ok, updated_wallet} ->
          {:ok, updated_wallet}

        {:error, changeset} ->
          {:error, changeset}
      end
    end)
  end

  @doc """
  Retrieves the balance of the wallet for a given user.
  If no wallet is found, it returns 0.
  """
  def get_balance(user_id) do
    case get_wallet_by_user(user_id) do
      nil ->
        {:error, "Wallet not found"}  # Explicit error case

      wallet ->
        {:ok, wallet.balance || 0}  # Wrap the balance in an ok tuple
    end
  end

end
