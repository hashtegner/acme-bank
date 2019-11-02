import Config

config :acme_bank, AcmeBank.Repo,
  database: "acme_bank_repo_prod",
  username: "postgres",
  password: "",
  hostname: "localhost"
