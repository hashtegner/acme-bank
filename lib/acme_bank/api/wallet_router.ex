defmodule AcmeBank.Api.WalletRouter do
  use Plug.Router

  alias AcmeBank.Api.Wallet.PlaceMoney, as: PlaceMoney
  alias AcmeBank.Api.Wallet.Summary, as: WalletSummary
  alias AcmeBank.Api.Wallet.Transfer, as: WalletTransfer

  plug(AcmeBank.Api.Auth)
  plug(:match)
  plug(:dispatch)

  get("/summary", to: WalletSummary)
  post("/transfer", to: WalletTransfer)
  post("/place", to: PlaceMoney)
end
