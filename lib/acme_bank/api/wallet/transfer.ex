defmodule AcmeBank.Api.Wallet.Transfer do
  alias AcmeBank.Kit.Web

  @wallet_service Application.get_env(:acme_bank, :wallet_service)

  def init(opts), do: opts

  def call(conn, _opts) do
    conn.body_params
    |> @wallet_service.transfer_money()
    |> case do
      {:ok, source_transaction, destination_transaction} ->
        Web.send_json(conn, 200, %{
          source_transaction: source_transaction,
          destination_transaction: destination_transaction
        })

      {:error, reason} ->
        Web.send_json(conn, 400, %{errors: reason})
    end
  end
end
