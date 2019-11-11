defmodule AcmeBank.Api.Accounts.Create do
  alias AcmeBank.Kit.Web

  @accounts_service Application.get_env(:acme_bank, :accounts_service)

  def init(opts), do: opts

  def call(conn, _opts) do
    conn.body_params
    |> @accounts_service.create_account()
    |> case do
      {:ok, account} -> Web.send_json(conn, 200, account)
      {:error, reason} -> Web.send_json(conn, 400, %{errors: reason})
    end
  end
end
