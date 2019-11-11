defmodule AcmeBank.Api.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger, otp_app: :acme_bank_api
  else
    use Plug.ErrorHandler
  end

  alias AcmeBank.Api.Accounts.Create, as: AccountCreate
  alias AcmeBank.Api.Health
  alias AcmeBank.Api.Wallet.PlaceMoney, as: PlaceMoney
  alias AcmeBank.Api.Wallet.Summary, as: WalletSummary
  alias AcmeBank.Api.Wallet.Transfer, as: WalletTransfer

  plug(Plug.RequestId)
  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get("/health", to: Health)

  post("/accounts", to: AccountCreate)

  get("/wallets/summary", to: WalletSummary)
  post("/wallets/transfer", to: WalletTransfer)
  post("/wallets/place", to: PlaceMoney)

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
