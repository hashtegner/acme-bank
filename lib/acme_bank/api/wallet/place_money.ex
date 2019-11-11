defmodule AcmeBank.Api.Wallet.PlaceMoney do
  alias AcmeBank.Kit.Web

  @wallet_service Application.get_env(:acme_bank, :wallet_service)

  def init(opts), do: opts

  def call(conn, _opts) do
    conn.body_params
    |> @wallet_service.place_money()
    |> case do
      {:ok, transaction} ->
        Web.send_json(conn, 200, transaction)

      {:error, reason} ->
        Web.send_json(conn, 400, %{errors: reason})
    end
  end
end
