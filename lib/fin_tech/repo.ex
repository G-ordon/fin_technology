defmodule FinTech.Repo do
  use Ecto.Repo,
    otp_app: :fin_tech,
    adapter: Ecto.Adapters.Postgres
end
