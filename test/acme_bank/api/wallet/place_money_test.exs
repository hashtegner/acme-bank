defmodule AcmeBank.Api.Wallet.PlaceMoneyTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Api.Router
  alias AcmeBank.Wallet.Transaction
  alias AcmeBank.{AuthMock, WalletMock}

  @opts Router.init([])

  test "valid request" do
    params = %{
      account_id: "abc-456",
      amount_cents: 15_990
    }

    transaction = %Transaction{
      amount_cents: 15_990,
      type: :place,
      account_id: "abc-456",
      id: "uuid-456",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    AuthMock
    |> expect(:verify_token, fn _ -> {:ok, %{account: "123"}} end)

    WalletMock
    |> expect(:place_money, fn %{
                                 "account_id" => "abc-456",
                                 "amount_cents" => 15_990
                               } ->
      {:ok, transaction}
    end)

    conn =
      conn(:post, "/wallets/place", params)
      |> Router.call(@opts)

    assert conn.status == 200

    assert conn.resp_body ==
             Jason.encode!(
               Map.take(transaction, [
                 :id,
                 :amount_cents,
                 :account_id,
                 :type,
                 :inserted_at,
                 :updated_at
               ])
             )
  end

  test "invalid request" do
    errors = %{
      amount_cents: [%{msg: "invalid", rules: [%{validation: :required}]}]
    }

    AuthMock
    |> expect(:verify_token, fn _ -> {:ok, %{account: "123"}} end)

    WalletMock
    |> expect(:place_money, fn %{} ->
      {:error, errors}
    end)

    conn = conn(:post, "/wallets/place")
    conn = Router.call(conn, @opts)

    assert conn.status == 400

    assert conn.resp_body == Jason.encode!(%{errors: errors})
  end

  test "invalid access token" do
    AuthMock
    |> expect(:verify_token, fn _ -> {:error, :invalid_access_token} end)

    conn =
      conn(:post, "/wallets/place")
      |> Router.call(@opts)

    assert conn.status == 401
  end
end
