defmodule FinTechWeb.USSDController do
  use FinTechWeb, :controller

  alias FinTech.USSDHandler
  alias FinTech.Accounts

  def handle(conn, %{"text" => text, "phoneNumber" => phone_number}) do
    case text do
      "1" ->
        handle_balance_check(conn, phone_number)

      _ ->
        response_message = USSDHandler.handle_request(text, phone_number)

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, response_message)
    end
  end

  def handle(conn, _) do
    conn
    |> put_status(:bad_request)
    |> put_resp_content_type("text/plain")
    |> send_resp(400, "Invalid request format. Please try again.")
  end

  defp handle_balance_check(conn, phone_number) do
    case Accounts.get_user_by_phone_number(phone_number) do
      nil ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_resp_content_type("text/plain")
        |> send_resp(422, "END User not found. Please register to use this service.")

      user ->
        case Accounts.get_balance(user.id) do
          {:ok, balance} ->
            response = "END Your balance is $#{balance}."
            conn
            |> put_resp_content_type("text/plain")
            |> send_resp(200, response)

          {:error, "Wallet not found"} ->
            conn
            |> put_status(:not_found)
            |> put_resp_content_type("text/plain")
            |> send_resp(404, "END Wallet not found for this user.")

          {:error, _reason} ->
            conn
            |> put_status(:internal_server_error)
            |> put_resp_content_type("text/plain")
            |> send_resp(500, "END Error retrieving balance. Please try again.")
        end
    end
  end


end
