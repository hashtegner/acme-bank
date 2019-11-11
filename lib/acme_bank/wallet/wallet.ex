defmodule AcmeBank.Wallet do
  alias AcmeBank.Accounts.Account
  alias AcmeBank.Kit.Changeset
  alias AcmeBank.{Repo, WalletBehaviour}
  alias AcmeBank.Wallet.{Transaction, Transfer}
  alias Ecto.Multi

  import Ecto.Query

  @behaviour WalletBehaviour

  @doc ~S"""
  Place money in account

  ## Examples
    iex> Wallet.place_money(%{account_id: "7738fdf8-f00f-4cb3-ab5f-da9dec21f666", amount_cents: 10000})
    {:ok,
      %AcmeBank.Wallet.Transaction{
      account: #Ecto.Association.NotLoaded<association :account is not loaded>,
      account_id: "7738fdf8-f00f-4cb3-ab5f-da9dec21f666",
      amount_cents: 10000,
      id: "038a8070-c6cd-452a-825b-545fabe21e01",
      inserted_at: ~N[2019-11-11 13:10:48],
      type: :place,
      updated_at: ~N[2019-11-11 13:10:48]
    }}
  """
  def place_money(params \\ %{}) do
    Multi.new()
    |> Multi.insert(:transaction, Transaction.place_money_changeset(params))
    |> Multi.merge(fn %{transaction: transaction} -> increase_wallet_amount(transaction) end)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction}} -> {:ok, transaction}
      {:error, :transaction, changeset, _} -> {:error, Changeset.traverse_errors(changeset)}
    end
  end

  @doc ~S"""
  Transfer money between accounts

  ## Examples
    iex> Wallet.transfer_money(%{source_account_id: "7738fdf8-f00f-4cb3-ab5f-da9dec21f666", destination_account_id: "1d6206e6-9736-44ef-adb0-11b6d4ed9057", amount_cents: 2000})
    {:ok,
      %AcmeBank.Wallet.Transaction{
        __meta__: #Ecto.Schema.Metadata<:loaded, "transactions">,
        account: #Ecto.Association.NotLoaded<association :account is not loaded>,
        account_id: "7738fdf8-f00f-4cb3-ab5f-da9dec21f666",
        amount_cents: -2000,
        id: "ae5f3049-5c86-439f-9749-51db98e1fc64",
        inserted_at: ~N[2019-11-11 13:18:49],
        type: :transfer,
        updated_at: ~N[2019-11-11 13:18:49]
      },
      %AcmeBank.Wallet.Transaction{
        __meta__: #Ecto.Schema.Metadata<:loaded, "transactions">,
        account: #Ecto.Association.NotLoaded<association :account is not loaded>,
        account_id: "1d6206e6-9736-44ef-adb0-11b6d4ed9057",
        amount_cents: 2000,
        id: "6a359af1-dfe2-45f0-a487-1bef6cadb107",
        inserted_at: ~N[2019-11-11 13:18:49],
        type: :transfer,
        updated_at: ~N[2019-11-11 13:18:49]
    }}
  """
  def transfer_money(params \\ %{}) do
    Multi.new()
    |> Multi.run(:transfer, fn _, _ -> Transfer.changeset(params) end)
    |> Multi.merge(fn %{transfer: transfer} -> send_transfer(transfer) end)
    |> Multi.merge(fn %{transfer: transfer} -> receive_transfer(transfer) end)
    |> Multi.run(:funds_guard, fn _, %{decrease_wallet: decrease_wallet_status} ->
      case decrease_wallet_status do
        {1, _} -> {:ok, nil}
        _ -> {:error, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{source_transaction: source_transaction, destination_transaction: destination_transaction}} ->
        {:ok, source_transaction, destination_transaction}

      {:error, :transfer, changeset, _} ->
        {:error, Changeset.traverse_errors(changeset)}

      {:error, :funds_guard, _, %{transfer: transfer}} ->
        errors =
          transfer
          |> Transfer.insufficient_funds()
          |> Changeset.traverse_errors()

        {:error, errors}
    end
  end

  defp receive_transfer(transfer) do
    params = %{account_id: transfer.destination_account_id, amount_cents: transfer.amount_cents}

    Multi.new()
    |> Multi.insert(:destination_transaction, Transaction.transfer_money_changeset(params))
    |> Multi.merge(fn %{destination_transaction: destination_transaction} ->
      increase_wallet_amount(destination_transaction)
    end)
  end

  defp send_transfer(transfer) do
    params = %{account_id: transfer.source_account_id, amount_cents: -transfer.amount_cents}

    Multi.new()
    |> Multi.insert(:source_transaction, Transaction.transfer_money_changeset(params))
    |> Multi.merge(fn %{source_transaction: source_transaction} ->
      decrease_wallet_amount(source_transaction)
    end)
  end

  defp decrease_wallet_amount(transaction) do
    from(a in Account,
      where:
        a.id == ^transaction.account_id and
          a.current_wallet_cents >= ^abs(transaction.amount_cents)
    )
    |> update_wallet_amount_by_query(:decrease_wallet, transaction)
  end

  defp increase_wallet_amount(transaction) do
    from(Account, where: [id: ^transaction.account_id])
    |> update_wallet_amount_by_query(:increase_wallet, transaction)
  end

  defp update_wallet_amount_by_query(query, operation, transaction) do
    Multi.new()
    |> Multi.update_all(operation, query, inc: [current_wallet_cents: transaction.amount_cents])
  end
end
