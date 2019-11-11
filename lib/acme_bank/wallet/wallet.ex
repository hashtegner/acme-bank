defmodule AcmeBank.Wallet do
  alias AcmeBank.Accounts.Account
  alias AcmeBank.{WalletBehaviour, Repo}
  alias AcmeBank.Wallet.Transaction
  alias AcmeBank.Kit.Changeset
  alias Ecto.Multi

  import Ecto.Query

  @behaviour WalletBehaviour

  def place_money(params \\ %{}) do
    Multi.new()
    |> Multi.insert(:transaction, Transaction.place_money_changeset(params))
    |> Multi.merge(fn %{transaction: transaction} ->
      update_wallet_amount(transaction)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction}} -> {:ok, transaction}
      {:error, :transaction, changeset, _} -> {:error, Changeset.traverse_errors(changeset)}
    end
  end

  defp update_wallet_amount(transaction) do
    query = from(Account, where: [id: ^transaction.account_id])

    Multi.new()
    |> Multi.update_all(:wallet, query, inc: [current_wallet_cents: transaction.amount_cents])
  end
end
