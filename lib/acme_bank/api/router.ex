defmodule AcmeBank.Api.Router do
  use AcmeBank.Kit.Plug

  alias AcmeBank.Api.Accounts.Create, as: AccountCreate
  alias AcmeBank.Api.{Health, WalletRouter}

  get("/health", to: Health)
  post("/accounts", to: AccountCreate)

  forward("/wallets", to: WalletRouter)

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
