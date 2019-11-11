import Config

config :acme_bank, AcmeBank.Auth.AccessToken,
  issuer: "acme_bank",
  secret_key: System.get_env("SECRET_KEY")

config :acme_bank, AcmeBank.Repo,
  database: "acme_bank_repo_prod",
  username: "postgres",
  password: "",
  hostname: "localhost"
