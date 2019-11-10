defmodule AcmeBank.Accounts.Account do
  alias AcmeBank.Accounts.Account
  use AcmeBank.Kit.Schema

  import Ecto.Changeset

  schema "accounts" do
    field(:name, :string)
    field(:current_wallet_cents, :integer, default: 0)
    timestamps()
  end

  def changeset(%Account{} = account, params \\ %{}) do
    account
    |> cast(params, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
