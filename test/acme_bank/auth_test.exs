defmodule AcmeBank.AuthTest do
  use AcmeBank.RepoCase
  alias AcmeBank.Auth
  alias AcmeBank.Auth.AccessToken

  describe "sign_up/1" do
    test "creates an account" do
      params = %{name: "My Account"}
      response = Auth.sign_up(params)

      assert {:ok, account, _access_token} = response
      assert account.name == "My Account"
      assert account.id != nil
    end

    test "generates a valid resource access token" do
      params = %{name: "My Account"}
      {:ok, account, access_token} = Auth.sign_up(params)

      decoded = AccessToken.decode_and_verify(access_token)
      assert {:ok, claims} = decoded

      resource = AccessToken.resource_from_claims(claims)
      assert {:ok, resource_id} = resource

      assert resource_id == account.id
    end

    test "invalid params should return errors" do
      response = Auth.sign_up(%{})

      assert {:error, _} = response
    end
  end

  describe "verify_token/1" do
    test "valid access token" do
      params = %{name: "My Account"}
      {:ok, expected_account, access_token} = Auth.sign_up(params)

      response = Auth.verify_token(access_token)

      assert {:ok, account} = response
      assert account == expected_account
    end

    test "invalid access token" do
      response = Auth.verify_token("abc-123")

      assert {:error, :invalid_access_token} = response
    end
  end
end
