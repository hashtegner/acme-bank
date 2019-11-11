import Config

config :acme_bank, :accounts_service, AcmeBank.AccountsMock
config :acme_bank, :auth_service, AcmeBank.AuthMock
config :acme_bank, :wallet_service, AcmeBank.WalletMock

config :acme_bank, AcmeBank.Repo,
  database: "acme_bank_repo_test",
  username: "postgres",
  password: "",
  port: System.get_env("DB_PORT", "5432") |> String.to_integer(),
  hostname: System.get_env("DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
