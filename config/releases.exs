import Config

config :acme_bank, :port, System.fetch_env!("PORT") |> String.to_integer()

config :acme_bank, AcmeBank.Auth.AccessToken,
  issuer: "acme_bank",
  secret_key: System.fetch_env!("SECRET_KEY")

config :acme_bank, AcmeBank.Repo, url: "ecto://#{System.fetch_env!("DATABASE_URL")}"
