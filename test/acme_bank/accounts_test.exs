defmodule AcmeBank.AccountsTest do
  use AcmeBank.RepoCase

  alias AcmeBank.Accounts

  describe "create_account/1" do
    test "given valid params" do
      params = %{name: "My Account"}

      response = Accounts.create_account(params)

      assert {:ok, account} = response
      assert account.name == "My Account"
      assert account.current_wallet_cents == 0
      assert account.id != nil
    end

    test "given empty params" do
      response = Accounts.create_account(%{})

      assert {:error, reason} = response

      assert reason == %{
               name: [
                 %{msg: "can't be blank", rules: %{validation: :required}}
               ]
             }
    end

    test "given account name that already exists" do
      params = %{name: "My Account"}

      {:ok, _} = Accounts.create_account(params)

      response = Accounts.create_account(params)

      assert {:error, reason} = response

      assert reason = %{
               name: [
                 %{
                   msg: "has already been taken",
                   rules: %{constraint: :unique, constraint_name: "accounts_name_index"}
                 }
               ]
             }
    end
  end

  describe "get_account/1" do
    test "account exists" do
      {:ok, expected_account} = Accounts.create_account(%{name: "My Account"})

      account = Accounts.get_account(expected_account.id)

      assert account == expected_account
    end

    test "account does not exists" do
      account = Accounts.get_account(Ecto.UUID.generate())

      assert account == nil
    end

    test "invalid uuid" do
      account = Accounts.get_account("abc-123")

      assert account == nil
    end
  end
end
