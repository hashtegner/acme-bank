defmodule AcmeBank.Wallet.Transfer do
  alias AcmeBank.Accounts
  alias AcmeBank.Wallet.Transfer
  use AcmeBank.Kit.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:source_account_id, :string)
    field(:destination_account_id, :string)
    field(:amount_cents, :integer)
  end

  def changeset(params \\ %{}) do
    %Transfer{}
    |> cast(params, [:source_account_id, :destination_account_id, :amount_cents])
    |> validate_required([:source_account_id, :destination_account_id, :amount_cents])
    |> validate_self_transfer(:source_account_id, :destination_account_id)
    |> validate_number(:amount_cents, greater_than: 0)
    |> validate_account(:source_account_id)
    |> validate_account(:destination_account_id)
    |> apply_action(:replace)
  end

  def insufficient_funds(%Transfer{} = transfer) do
    transfer
    |> change()
    |> add_error(:amount_cents, "insufficient funds", validation: :required_funds)
  end

  defp validate_self_transfer(changeset, source_attr, destination_attr) do
    source_id = get_field(changeset, source_attr)
    destination_id = get_field(changeset, destination_attr)

    cond do
      destination_id == nil ->
        changeset

      source_id == destination_id ->
        add_error(changeset, destination_attr, "must be different from source account id",
          validation: :self_transfer
        )

      true ->
        changeset
    end
  end

  defp validate_account(changeset, attr) do
    account_id = get_field(changeset, attr)

    cond do
      account_id == nil ->
        changeset

      Accounts.get_account(account_id) == nil ->
        add_error(changeset, attr, "does not exists", constraint: :assoc)

      true ->
        changeset
    end
  end
end
