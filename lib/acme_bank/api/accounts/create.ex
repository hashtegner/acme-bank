defmodule AcmeBank.Api.Accounts.Create do
  alias AcmeBank.Kit.Web

  @auth_service Application.get_env(:acme_bank, :auth_service)

  def init(opts), do: opts

  def call(conn, _opts) do
    conn.body_params
    |> @auth_service.sign_up()
    |> case do
      {:ok, account, access_token} ->
        Web.send_json(conn, 200, %{account: account, access_token: access_token})

      {:error, reason} ->
        Web.send_json(conn, 400, %{errors: reason})
    end
  end
end
