defmodule AcmeBank.Api.Wallet.TransferTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Api.Router
  alias AcmeBank.WalletMock
  alias AcmeBank.Wallet.Transaction

  @opts Router.init([])

  test "valid request" do
    params = %{
      source_account_id: "abc-123",
      destination_account_id: "abc-456",
      amount_cents: 159_90,
      id: "uuid-123",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    transaction_a = %Transaction{
      amount_cents: -159_90,
      type: :transfer,
      account_id: "abc-123",
      id: "uuid-456",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    transaction_b = %Transaction{
      amount_cents: 159_90,
      type: :transfer,
      account_id: "abc-456"
    }

    WalletMock
    |> expect(:transfer_money, fn %{
                                    "source_account_id" => "abc-123",
                                    "destination_account_id" => "abc-456",
                                    "amount_cents" => 15_990
                                  } ->
      {:ok, transaction_a, transaction_b}
    end)

    conn = conn(:post, "/wallets/transfer", params)
    conn = Router.call(conn, @opts)

    assert conn.status == 200

    assert conn.resp_body ==
             Jason.encode!(%{
               source_transaction: transaction_a,
               destination_transaction: transaction_b
             })
  end

  test "invalid request" do
    params = %{}
    errors = %{amount_cents: [%{msg: "invalid", rules: [%{validation: :required}]}]}

    WalletMock
    |> expect(:transfer_money, fn %{} ->
      {:error, errors}
    end)

    conn = conn(:post, "/wallets/transfer", params)

    conn = Router.call(conn, @opts)

    assert conn.status == 400

    assert conn.resp_body ==
             Jason.encode!(%{errors: errors})
  end
end
