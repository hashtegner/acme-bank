import Config

config :acme_bank, AcmeBank.Repo,
  database: "acme_bank_repo_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
