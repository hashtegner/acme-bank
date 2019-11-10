defmodule AcmeBank.AccountsBehavior do
  @callback create_account(Map.t()) ::
              {:ok, AcmeBank.Accounts.Account.t()} | {:error, AcmeBank.Kit.Changeset.errors()}

  @callback get_account(String.t()) :: AcmeBank.Accounts.Account.t() | nil
end
