defmodule AcmeBank.Wallet.Transaction do
  alias AcmeBank.Accounts.Account
  alias AcmeBank.Wallet.{Transaction, TransactionTypeEnum}
  use AcmeBank.Kit.Schema

  import Ecto.Changeset

  schema "transactions" do
    belongs_to(:account, Account)
    field(:type, TransactionTypeEnum)
    field(:amount_cents, :integer)
    timestamps()
  end

  def place_money_changeset(params \\ %{}) do
    %Transaction{type: :place}
    |> default_changeset(params)
    |> validate_number(:amount_cents, greater_than: 0)
  end

  def transfer_money_changeset(params \\ %{}) do
    %Transaction{type: :transfer}
    |> default_changeset(params)
  end

  defp default_changeset(changeset, params) do
    changeset
    |> cast(params, [:amount_cents, :account_id])
    |> validate_required([:amount_cents, :account_id])
    |> assoc_constraint(:account_id, name: :transactions_account_id_fkey)
  end
end
