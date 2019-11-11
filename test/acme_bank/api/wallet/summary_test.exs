defmodule AcmeBank.Api.Wallet.SummaryTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Api.Router
  alias AcmeBank.{AuthMock, WalletMock}

  @opts Router.init([])

  test "valid request" do
    account_id = "abc-123"

    AuthMock
    |> expect(:verify_token, fn _ -> {:ok, %{account: "123"}} end)

    WalletMock
    |> expect(:summary, fn "abc-123" -> {:ok, 12_990} end)

    conn = conn(:get, "/wallets/summary", %{account_id: account_id})
    conn = Router.call(conn, @opts)

    assert conn.status == 200

    assert conn.resp_body ==
             Jason.encode!(%{account_id: account_id, amount_cents: 12_990})
  end

  test "invalid request" do
    account_id = "abc-123"

    AuthMock
    |> expect(:verify_token, fn _ -> {:ok, %{account: "123"}} end)

    WalletMock
    |> expect(:summary, fn "abc-123" -> {:error, 0} end)

    conn = conn(:get, "/wallets/summary", %{account_id: account_id})

    conn = Router.call(conn, @opts)

    assert conn.status == 404

    assert conn.resp_body ==
             Jason.encode!("account not found")
  end

  test "invalid access token" do
    AuthMock
    |> expect(:verify_token, fn _ -> {:error, :invalid_access_token} end)

    conn =
      conn(:get, "/wallets/summary")
      |> Router.call(@opts)

    assert conn.status == 401
  end
end
