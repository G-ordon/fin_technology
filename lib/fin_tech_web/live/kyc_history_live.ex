defmodule FinTechWeb.KycHistoryLive do
  use FinTechWeb, :live_view

  alias FinTech.Accounts

  def mount(_params, %{"user_token" => token} = _session, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        # If no user is found, redirect to the login page
        {:ok, put_flash(socket, :error, "You must be logged in to access your KYC history.")
        |> redirect(to: "/users/log_in")}

      user ->
        # Fetch the user's KYC records
        kyc_records = Accounts.get_kyc_by_user(user.id)
        {:ok, assign(socket, kyc_records: kyc_records, current_user: user)}
    end
  end

  def render(assigns) do
    ~H"""
    <h2><strong>KYC Submission History</strong></h2>

    <table>
      <thead>
        <tr>
          <th>Full Name</th>
          <th>Address</th>
          <th>Document Type</th>
          <th>Document Number</th>
          <th>Submitted At</th>
        </tr>
      </thead>
      <tbody>
        <%= if @kyc_records == [] do %>
          <tr>
            <td colspan="5" style="text-align: center;">No KYC records found.</td>
          </tr>
        <% else %>
          <%= for kyc <- @kyc_records do %>
            <tr>
              <td><%= kyc.full_name %></td>
              <td><%= kyc.address %></td>
              <td><%= kyc.document_type %></td>
              <td><%= kyc.document_number %></td>
              <td><%= format_inserted_at(kyc.inserted_at) %></td>
            </tr>
          <% end %>
        <% end %>
      </tbody>
    </table>
    """
  end

  # Format inserted_at using NaiveDateTime
  defp format_inserted_at(inserted_at) do
    NaiveDateTime.to_string(inserted_at) # Converts NaiveDateTime to a string in the format "YYYY-MM-DD HH:MM:SS"
  end
end
