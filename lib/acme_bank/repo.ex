defmodule AcmeBank.Repo do
  use Ecto.Repo,
    otp_app: :acme_bank,
    adapter: Ecto.Adapters.Postgres
end
