defmodule AcmeBank.WalletBehavior do
  @callback place_money(Map.t()) ::
              {:ok, AcmeBank.Wallet.Transaction.t()} | {:error, AcmeBank.Kit.Changeset.errors()}
end
