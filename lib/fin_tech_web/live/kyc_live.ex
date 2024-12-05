defmodule FinTechWeb.KycLive do
  use FinTechWeb, :live_view

  alias FinTech.Accounts
  alias FinTech.Accounts.KYC

  def mount(_params, %{"user_token" => token} = _session, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        {:ok, put_flash(socket, :error, "You must be logged in to submit KYC.")
        |> redirect(to: "/users/log_in")}

      user ->
        kyc = %KYC{}
        changeset = Accounts.change_kyc(kyc, %{})
        {:ok, assign(socket, changeset: changeset, submitted: false, current_user: user)}
    end
  end

  def handle_event("submit", %{"kyc" => kyc_params}, socket) do
    user_id = socket.assigns.current_user.id  # Get the current user's ID

    # Create a changeset from the KYC parameters and include the user_id
    kyc_params_with_user_id = Map.put(kyc_params, "user_id", user_id)
    changeset = Accounts.change_kyc(%KYC{}, kyc_params_with_user_id)

    case Accounts.submit_kyc(changeset) do
      {:ok, _kyc_record} ->
        # Set a flash message and redirect to the KYC history page or another page
        socket = put_flash(socket, :info, "KYC submitted successfully!")
        {:noreply, redirect(socket, to: "/kyc/history")}  # Redirect after submission

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="kyc-form-container">
      <h2><strong>Submit KYC</strong></h2>

      <%= if @changeset.errors != [] do %>
        <div class="error-messages">
          <ul>
            <%= for {field, {message, _}} <- @changeset.errors do %>
              <li><%= humanize(field) %>: <%= message %></li>
            <% end %>
          </ul>
        </div>
      <% end %>

      <form phx-submit="submit">
        <div class="form-group">
          <label for="full_name">Full Name</label>
          <input type="text" name="kyc[full_name]" id="full_name" value={@changeset.data.full_name} required placeholder="Enter your full name" />
        </div>
        <div class="form-group">
          <label for="address">Address</label>
          <input type="text" name="kyc[address]" id="address" value={@changeset.data.address} required placeholder="Enter your address" />
        </div>
        <div class="form-group">
          <label for="document_type">Document Type</label>
          <input type="text" name="kyc[document_type]" id="document_type" value={@changeset.data.document_type} required placeholder="e.g., Passport, ID Card" />
        </div>
        <div class="form-group">
          <label for="document_number">Document Number</label>
          <input type="text" name="kyc[document_number]" id="document_number" value={@changeset.data.document_number} required placeholder="Enter your document number" />
        </div>
        <button type="submit" class="submit-button">Submit</button>
      </form>
    </div>
    """
  end

  # Helper function to convert field names to a user-friendly format
  defp humanize(field) do
    field
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
