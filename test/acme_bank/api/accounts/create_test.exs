defmodule AcmeBank.Api.Accounts.CreateTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Accounts.Account
  alias AcmeBank.AuthMock
  alias AcmeBank.Api.Router

  @opts Router.init([])

  test "valid request" do
    account = %Account{
      name: "My Account",
      id: "abc-123",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    AuthMock
    |> expect(:sign_up, fn %{"name" => "My Account"} -> {:ok, account, "abc"} end)

    conn = conn(:post, "/accounts", %{name: "My Account"})

    conn = Router.call(conn, @opts)

    assert conn.status == 200

    assert conn.resp_body ==
             Jason.encode!(%{
               account: Map.take(account, [:id, :name, :inserted_at, :updated_at]),
               access_token: "abc"
             })
  end

  test "invalid request" do
    errors = %{
      name: [%{msg: "is required", rules: %{validation: :requierd}}]
    }

    AuthMock
    |> expect(:sign_up, fn %{} -> {:error, errors} end)

    conn = conn(:post, "/accounts")

    conn = Router.call(conn, @opts)

    assert conn.status == 400

    assert conn.resp_body ==
             Jason.encode!(%{errors: errors})
  end
end
