defmodule FinTech.USSDState do
  # Function to put a user state
  def put_user_state(phone_number, state) do
    # Insert the user state into the ETS table
    :ets.insert(:user_states, {phone_number, state})
  end

  # Function to get a user state
  def get_user_state(phone_number) do
    case :ets.lookup(:user_states, phone_number) do
      [] -> nil
      [{_phone_number, state}] -> state
    end
  end

  # Function to remove a user state
  def remove_user_state(phone_number) do
    :ets.delete(:user_states, phone_number)
  end

  # Initialize the ETS table
  def start_link do
    :ets.new(:user_states, [:named_table, :public, read_concurrency: true])
  end
end
