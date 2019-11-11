import Config

config :acme_bank, :accounts_service, AcmeBank.AccountsMock
config :acme_bank, :wallet_service, AcmeBank.WalletMock

config :acme_bank, AcmeBank.Repo,
  database: "acme_bank_repo_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
