defmodule AcmeBank.Api.Wallet.TransferTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Api.Router
  alias AcmeBank.Wallet.Transaction
  alias AcmeBank.{AuthMock, WalletMock}

  @opts Router.init([])

  test "valid request" do
    params = %{
      source_account_id: "abc-123",
      destination_account_id: "abc-456",
      amount_cents: 15_990,
      id: "uuid-123"
    }

    transaction_a = %Transaction{
      amount_cents: -15_990,
      type: :transfer,
      account_id: "abc-123",
      id: "uuid-456",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    transaction_b = %Transaction{
      amount_cents: 15_990,
      type: :transfer,
      account_id: "abc-456",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    AuthMock
    |> expect(:verify_token, fn _ -> {:ok, %{account: "123"}} end)

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

    AuthMock
    |> expect(:verify_token, fn _ -> {:ok, %{account: "123"}} end)

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

  test "invalid access token" do
    AuthMock
    |> expect(:verify_token, fn _ -> {:error, :invalid_access_token} end)

    conn =
      conn(:post, "/wallets/transfer")
      |> Router.call(@opts)

    assert conn.status == 401
  end
end
