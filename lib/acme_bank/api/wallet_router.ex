defmodule AcmeBank.Api.WalletRouter do
  use AcmeBank.Kit.Plug

  alias AcmeBank.Api.Wallet.PlaceMoney, as: PlaceMoney
  alias AcmeBank.Api.Wallet.Summary, as: WalletSummary
  alias AcmeBank.Api.Wallet.Transfer, as: WalletTransfer

  get("/summary", to: WalletSummary)
  post("/transfer", to: WalletTransfer)
  post("/place", to: PlaceMoney)
end
