import Config

config :acme_bank, :accounts_service, AcmeBank.Accounts
config :acme_bank, :wallet_service, AcmeBank.Wallet

config :acme_bank, ecto_repos: [AcmeBank.Repo]
config :acme_bank, AcmeBank.Repo, migration_primary_key: [name: :id, type: :binary_id]

import_config "#{Mix.env()}.exs"
