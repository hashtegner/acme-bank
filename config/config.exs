import Config

config :acme_bank, ecto_repos: [AcmeBank.Repo]

import_config "#{Mix.env()}.exs"
