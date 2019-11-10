defmodule AcmeBank.Accounts do
  alias AcmeBank.Accounts.{Account}
  alias AcmeBank.Kit.Changeset
  alias AcmeBank.Repo
  alias Ecto.UUID

  @behaviour AcmeBank.AccountsBehavior

  @doc ~S"""
  Create a new account

  ## Examples
    iex> Accounts.create_account(%{name: "My Account"})
    {:ok,
      %AcmeBank.Accounts.Account{
      current_wallet_cents: 0,
      id: "44199de8-9e7c-4138-9c53-ceff2e709cb7",
      inserted_at: ~N[2019-11-10 13:54:43],
      name: "My Account",
      updated_at: ~N[2019-11-10 13:54:43]
    }}
  """
  def create_account(params \\ %{}) do
    %Account{}
    |> Account.changeset(params)
    |> Repo.insert()
    |> case do
      {:error, changeset} -> {:error, Changeset.traverse_errors(changeset)}
      success -> success
    end
  end

  @doc ~S"""
  Get an existent account

  ## Examples
    iex> Accounts.get_account("44199de8-9e7c-4138-9c53-ceff2e709cb7")
    %AcmeBank.Accounts.Account{
      current_wallet_cents: 0,
      id: "44199de8-9e7c-4138-9c53-ceff2e709cb7",
      inserted_at: ~N[2019-11-10 13:54:43],
      name: "My Account",
      updated_at: ~N[2019-11-10 13:54:43]
    }
  """

  def get_account(id) do
    case UUID.cast(id) do
      {:ok, uuid} -> Repo.get(Account, uuid)
      :error -> nil
    end
  end
end
