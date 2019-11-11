defmodule AcmeBank.Api.AuthTest do
  use AcmeBank.ConnCase
  alias AcmeBank.Accounts.Account
  alias AcmeBank.Api.Auth
  alias AcmeBank.AuthMock

  @opts Auth.init([])

  test "valid access token" do
    access_token = "abc"
    account = %Account{name: "my account"}

    AuthMock
    |> expect(:verify_token, fn "abc" -> {:ok, account} end)

    response =
      conn(:get, "/foo")
      |> put_req_header("authorization", "Bearer #{access_token}")
      |> Auth.call(@opts)

    assert response.assigns[:current_account] == account
  end

  test "without authorization header" do
    AuthMock
    |> expect(:verify_token, fn "" -> {:error, :invalid_access_token} end)

    response =
      conn(:get, "/foo")
      |> Auth.call(@opts)

    assert response.assigns[:current_account] == nil
    assert response.status == 401
    assert response.halted
  end
end
