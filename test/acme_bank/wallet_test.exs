defmodule AcmeBank.WalletTest do
  use AcmeBank.RepoCase

  alias AcmeBank.{Accounts, Wallet}
  alias Ecto.UUID

  describe "place_money/1" do
    test "creates a transaction" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})

      params = %{account_id: account.id, amount_cents: 19990}
      response = Wallet.place_money(params)

      assert {:ok, transaction} = response
      assert transaction.id != nil
      assert transaction.amount_cents == 19990
      assert transaction.account_id == account.id
      assert transaction.type == :place
    end

    test "increases wallet summary" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})

      Enum.each([10000, 20000, 50000], fn amount ->
        params = %{account_id: account.id, amount_cents: amount}
        {:ok, _} = Wallet.place_money(params)
      end)

      account = Accounts.get_account(account.id)
      assert account.current_wallet_cents == 80000
    end

    test "with errors, does not change wallet summary" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})

      params = %{account_id: account.id, amount_cents: "abc"}
      {:error, _} = Wallet.place_money(params)

      account = Accounts.get_account(account.id)
      assert account.current_wallet_cents == 0
    end

    test "validates blank params" do
      response = Wallet.place_money(%{})

      assert {:error, reason} = response

      assert reason == %{
               account_id: [%{msg: "can't be blank", rules: %{validation: :required}}],
               amount_cents: [%{msg: "can't be blank", rules: %{validation: :required}}]
             }
    end

    test "validates invalid account and amount data" do
      response = Wallet.place_money(%{account_id: 123, amount_cents: "abc"})

      assert {:error, reason} = response

      assert reason == %{
               account_id: [%{msg: "is invalid", rules: %{validation: :cast, type: :binary_id}}],
               amount_cents: [%{msg: "is invalid", rules: %{validation: :cast, type: :integer}}]
             }
    end

    test "validates account existence" do
      response = Wallet.place_money(%{account_id: UUID.generate(), amount_cents: 199})

      assert {:error, reason} = response

      assert reason == %{
               account_id: [
                 %{
                   msg: "does not exist",
                   rules: %{constraint: :assoc, constraint_name: "transactions_account_id_fkey"}
                 }
               ]
             }
    end

    test "validates negative amount" do
      response = Wallet.place_money(%{account_id: UUID.generate(), amount_cents: -100})

      assert {:error, reason} = response

      assert reason == %{
               amount_cents: [
                 %{
                   msg: "must be greater than 0",
                   rules: %{kind: :greater_than, number: 0, validation: :number}
                 }
               ]
             }
    end
  end
end
