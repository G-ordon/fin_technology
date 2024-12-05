defmodule FinTech.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FinTechWeb.Telemetry,
      FinTech.Repo,
      {DNSCluster, query: Application.get_env(:fin_tech, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FinTech.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FinTech.Finch},
      # Start a worker by calling: FinTech.Worker.start_link(arg)
      # {FinTech.Worker, arg},
      # Start to serve requests, typically the last entry
      FinTechWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinTech.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinTechWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
