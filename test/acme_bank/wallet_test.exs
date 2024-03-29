defmodule AcmeBank.WalletTest do
  use AcmeBank.RepoCase

  alias AcmeBank.{Accounts, Wallet}
  alias Ecto.UUID

  describe "place_money/1" do
    test "creates a transaction" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})

      params = %{account_id: account.id, amount_cents: 19_990}
      response = Wallet.place_money(params)

      assert {:ok, transaction} = response
      assert transaction.id != nil
      assert transaction.amount_cents == 19_990
      assert transaction.account_id == account.id
      assert transaction.type == :place
    end

    test "updates wallet summary" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})

      Enum.each([10_000, 20_000, 50_000], fn amount ->
        params = %{account_id: account.id, amount_cents: amount}
        {:ok, _} = Wallet.place_money(params)
      end)

      account = Accounts.get_account(account.id)
      assert account.current_wallet_cents == 80_000
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

  describe "transfer_money/1" do
    test "creates transactions" do
      {:ok, account_a} = Accounts.create_account(%{name: "My account"})
      {:ok, account_b} = Accounts.create_account(%{name: "My account B"})
      {:ok, _} = Wallet.place_money(%{account_id: account_a.id, amount_cents: 50_000})

      response =
        Wallet.transfer_money(%{
          source_account_id: account_a.id,
          destination_account_id: account_b.id,
          amount_cents: 25_000
        })

      assert {:ok, transaction_a, transaction_b} = response
      assert transaction_a.id != nil
      assert transaction_a.account_id == account_a.id
      assert transaction_a.amount_cents == -25_000
      assert transaction_a.type == :transfer

      assert transaction_b.id != nil
      assert transaction_b.account_id == account_b.id
      assert transaction_b.amount_cents == 25_000
      assert transaction_b.type == :transfer
    end

    test "updates wallet summaries" do
      {:ok, account_a} = Accounts.create_account(%{name: "My account"})
      {:ok, account_b} = Accounts.create_account(%{name: "My account B"})
      {:ok, _} = Wallet.place_money(%{account_id: account_a.id, amount_cents: 50_000})
      {:ok, _} = Wallet.place_money(%{account_id: account_b.id, amount_cents: 3000})

      {:ok, _, _} =
        Wallet.transfer_money(%{
          source_account_id: account_a.id,
          destination_account_id: account_b.id,
          amount_cents: 25_000
        })

      account_a = Accounts.get_account(account_a.id)
      account_b = Accounts.get_account(account_b.id)

      assert account_a.current_wallet_cents == 25_000
      assert account_b.current_wallet_cents == 28_000
    end

    test "insufficient funds validation" do
      {:ok, account_a} = Accounts.create_account(%{name: "My account"})
      {:ok, account_b} = Accounts.create_account(%{name: "My account B"})
      {:ok, _} = Wallet.place_money(%{account_id: account_a.id, amount_cents: 50_000})

      response =
        Wallet.transfer_money(%{
          source_account_id: account_a.id,
          destination_account_id: account_b.id,
          amount_cents: 80_000
        })

      assert {:error, reason} = response

      assert reason == %{
               amount_cents: [%{msg: "insufficient funds", rules: %{validation: :required_funds}}]
             }
    end

    test "with errors, does not change wallet summaries" do
      {:ok, account_a} = Accounts.create_account(%{name: "My account"})
      {:ok, account_b} = Accounts.create_account(%{name: "My account B"})
      {:ok, _} = Wallet.place_money(%{account_id: account_a.id, amount_cents: 50_000})
      {:ok, _} = Wallet.place_money(%{account_id: account_b.id, amount_cents: 30_000})

      {:error, _} =
        Wallet.transfer_money(%{
          source_account_id: account_a.id,
          destination_account_id: account_b.id,
          amount_cents: 80_000
        })

      account_a = Accounts.get_account(account_a.id)
      account_b = Accounts.get_account(account_b.id)

      assert account_a.current_wallet_cents == 50_000
      assert account_b.current_wallet_cents == 30_000
    end

    test "validates blank params" do
      response = Wallet.transfer_money(%{})

      assert {:error, reason} = response

      assert reason == %{
               source_account_id: [%{msg: "can't be blank", rules: %{validation: :required}}],
               destination_account_id: [
                 %{msg: "can't be blank", rules: %{validation: :required}}
               ],
               amount_cents: [%{msg: "can't be blank", rules: %{validation: :required}}]
             }
    end

    test "validates accounts existence" do
      response =
        Wallet.transfer_money(%{
          source_account_id: UUID.generate(),
          destination_account_id: UUID.generate(),
          amount_cents: 20
        })

      assert {:error, reason} = response

      assert reason == %{
               source_account_id: [%{msg: "does not exists", rules: %{constraint: :assoc}}],
               destination_account_id: [%{msg: "does not exists", rules: %{constraint: :assoc}}]
             }
    end

    test "validates same source and destination" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})

      response =
        Wallet.transfer_money(%{
          source_account_id: account.id,
          destination_account_id: account.id,
          amount_cents: 20
        })

      assert {:error, reason} = response

      assert reason == %{
               destination_account_id: [
                 %{
                   msg: "must be different from source account id",
                   rules: %{validation: :self_transfer}
                 }
               ]
             }
    end

    test "validates negative amount" do
      {:ok, account} = Accounts.create_account(%{name: "My account"})
      {:ok, account_b} = Accounts.create_account(%{name: "My account b"})

      response =
        Wallet.transfer_money(%{
          source_account_id: account.id,
          destination_account_id: account_b.id,
          amount_cents: -20
        })

      assert {:error, reason} = response

      assert reason == %{
               amount_cents: [
                 %{
                   msg: "must be greater than 0",
                   rules: %{validation: :number, kind: :greater_than, number: 0}
                 }
               ]
             }
    end
  end

  describe "summary/1" do
    test "wallet summary for existent account" do
      {:ok, account} = Accounts.create_account(%{name: "My Account"})
      {:ok, _} = Wallet.place_money(%{account_id: account.id, amount_cents: 150_000})

      response = Wallet.summary(account.id)
      assert {:ok, 150_000} == response
    end

    test "account does not exists" do
      response = Wallet.summary(UUID.generate())

      assert {:error, 0} == response
    end
  end
end
