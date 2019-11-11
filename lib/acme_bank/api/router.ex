defmodule AcmeBank.Api.Router do
  use AcmeBank.Kit.Plug

  alias AcmeBank.Api.Accounts.Create, as: AccountCreate
  alias AcmeBank.Api.{Health, WalletRouter}

  plug(:match)
  plug(:dispatch)

  get("/health", to: Health)
  post("/accounts", to: AccountCreate)

  forward("/wallets", to: WalletRouter)

  match _ do
    send_resp(conn, 404, "Not found")
  end

  def handle_errors(conn, _) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
