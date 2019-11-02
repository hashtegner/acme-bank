import Config

config :acme_bank, ecto_repos: [AcmeBank.Repo]

config :acme_bank, AcmeBank.Repo,
  database: "acme_bank_repo",
  username: "postgres",
  password: "",
  hostname: "localhost"
