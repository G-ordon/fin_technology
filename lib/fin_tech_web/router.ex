defmodule FinTechWeb.Router do
  use FinTechWeb, :router

  import FinTechWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FinTechWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", FinTechWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/cash_in", CashInLive, :index
    live "/cash_out", CashOutLive, :index
    live "/transfer", TransferLive, :index
    live "/ussd", USSDLive
  end

  # USSD API route
  scope "/api", FinTechWeb do
    pipe_through :api  # Use API pipeline for JSON requests

    post "/ussd", USSDController, :handle  # Route for handling USSD POST requests
  end

  # Development routes (for debugging and testing)
  if Application.compile_env(:fin_tech, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FinTechWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## User Authentication Routes
  scope "/", FinTechWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{FinTechWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  ## Authenticated User Routes
  scope "/", FinTechWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FinTechWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/users/kyc", KycLive, :new
      live "/kyc/history", KycHistoryLive, :index
      live "/transaction_history", TransactionHistoryLive
      live "/wallet", WalletLive, :index
    end
  end

  # Additional user session management routes
  scope "/", FinTechWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{FinTechWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
