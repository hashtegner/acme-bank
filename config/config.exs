import Config

config :acme_bank, :port, System.get_env("PORT", "4001") |> String.to_integer()
config :acme_bank, :accounts_service, AcmeBank.Accounts
config :acme_bank, :wallet_service, AcmeBank.Wallet
config :acme_bank, :auth_service, AcmeBank.Auth

config :acme_bank, AcmeBank.Auth.AccessToken,
  issuer: "acme_bank",
  secret_key: "jEcz2915fwDLObCnuZKDCosoF2T4nN5nW7KMBY1XjUdxOpirfzkfLx9hLW/PkUKk"

config :acme_bank, ecto_repos: [AcmeBank.Repo]
config :acme_bank, AcmeBank.Repo, migration_primary_key: [name: :id, type: :binary_id]

import_config "#{Mix.env()}.exs"
