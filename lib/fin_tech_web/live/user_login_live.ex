defmodule FinTechWeb.UserLoginLive do
  use FinTechWeb, :live_view
  alias FinTech.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen bg-gradient-to-r from-blue-100 to-teal-100">
      <div class="w-full max-w-md p-8 space-y-6 bg-white rounded-lg shadow-lg">
        <.header class="text-center text-2xl font-bold text-blue-600">
          Log in to your account
          <:subtitle>
            <p class="mt-2 text-sm text-gray-600">
              Don’t have an account?
              <.link navigate={~p"/users/register"} class="font-semibold text-blue-600 hover:underline">
                Sign up
              </.link>
              for an account now.
            </p>
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore" class="space-y-4">
          <!-- Email Field -->
          <.input field={@form[:email]} type="email" label="Email" required class="w-full p-3 border rounded-lg text-gray-700 focus:ring focus:ring-blue-200" />

          <!-- Password Field -->
          <.input field={@form[:password]} type="password" label="Password" required class="w-full p-3 border rounded-lg text-gray-700 focus:ring focus:ring-blue-200" />

          <!-- Actions Row -->
          <:actions>
            <div class="flex items-center justify-between">
              <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" class="text-blue-600" />
              <.link href={~p"/users/reset_password"} class="text-sm font-semibold text-blue-600 hover:underline">
                Forgot your password?
              </.link>
            </div>
          </:actions>

          <!-- Submit Button -->
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full py-2 text-white bg-blue-600 rounded-lg font-semibold hover:bg-blue-700 transition duration-200 ease-in-out shadow-md">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  def handle_event("login", %{"user" => %{"email" => email, "password" => password}}, socket) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Accounts.generate_user_session_token(user)
        {:noreply,
         socket
         |> put_flash(:info, "Welcome back!")
         |> assign(:user_token, token)
         |> push_navigate(to: "/")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Invalid email or password")}
    end
  end
end
