defmodule AcmeBank.AuthBehaviour do
  @callback sign_up(Map.t()) ::
              {:ok, AcmeBank.Accounts.Account.t(), String.t()}
              | {:error, AcmeBank.Kit.Changeset.errors()}

  @callback verify_token(String.t()) :: {:ok, AcmeBank.Accounts.Account.t()} | {:error, atom}
end
