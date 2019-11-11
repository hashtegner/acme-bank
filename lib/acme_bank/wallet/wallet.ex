defmodule AcmeBank.Wallet do
  alias AcmeBank.Accounts.Account
  alias AcmeBank.Kit.Changeset
  alias AcmeBank.{Repo, WalletBehaviour}
  alias AcmeBank.Wallet.{Transaction, Transfer}
  alias Ecto.Multi

  import Ecto.Query

  @behaviour WalletBehaviour

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
