defmodule AcmeBank.Api.Wallet.Summary do
  alias AcmeBank.Kit.Web

  @wallet_service Application.get_env(:acme_bank, :wallet_service)

  def init(opts), do: opts

  def call(conn, _opts) do
    account_id = conn.params["account_id"]

    account_id
    |> @wallet_service.summary()
    |> case do
      {:ok, amount_cents} ->
        Web.send_json(conn, 200, %{account_id: account_id, amount_cents: amount_cents})

      {:error, _} ->
        Web.send_json(conn, 404, "account not found")
    end
  end
end
