defmodule AcmeBank.Auth do
  alias AcmeBank.{Accounts, AuthBehaviour}
  alias AcmeBank.Auth.AccessToken

  @behaviour AuthBehaviour

  @doc ~S"""
  Sign up a new account

  ## Examples
    iex> Auth.sign_up(%{name: "My account"})
  {:ok,
    %AcmeBank.Accounts.Account{
      current_wallet_cents: 0,
      id: "649848e2-bd9f-4207-b280-fc417479156e",
      inserted_at: ~N[2019-11-11 17:29:25],
      name: "alesshh",
      updated_at: ~N[2019-11-11 17:29:25]
    },
    "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY21lX2JhbmsiLCJleHAiOjE1NzU5MTI1NjUsImlhdCI6MTU3MzQ5MzM2NSwiaXNzIjoiYWNtZV9iYW5rIiwianRpIjoiYmM4NjZhNzQtZGZmYS00MmZlLTlkMjktMmNmNmNhNDdmZjZmIiwibmJmIjoxNTczNDkzMzY0LCJzdWIiOiI2NDk4NDhlMi1iZDlmLTQyMDctYjI4MC1mYzQxNzQ3OTE1NmUiLCJ0eXAiOiJhY2Nlc3MifQ.nw32s30-PXkcD3b2Yph5o7RATS9brCoS8gwZDQqaTp9S4-0qOnOoXBJtksTlkB287bBkzaoNn6vgpADIC6JK4w"
  }
  """

  def sign_up(params \\ %{}) do
    with {:ok, account} <- Accounts.create_account(params),
         {:ok, access_token, _claims} <- AccessToken.encode_and_sign(account) do
      {:ok, account, access_token}
    else
      errors -> errors
    end
  end

  @doc ~S"""
  Verify account access token

  ## Examples
    iex> Auth.verify("eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY21lX2JhbmsiLCJleHAiOjE1NzU5MTI1NjUsImlhdCI6MTU3MzQ5MzM2NSwiaXNzIjoiYWNtZV9iYW5rIiwianRpIjoiYmM4NjZhNzQtZGZmYS00MmZlLTlkMjktMmNmNmNhNDdmZjZmIiwibmJmIjoxNTczNDkzMzY0LCJzdWIiOiI2NDk4NDhlMi1iZDlmLTQyMDctYjI4MC1mYzQxNzQ3OTE1NmUiLCJ0eXAiOiJhY2Nlc3MifQ.nw32s30-PXkcD3b2Yph5o7RATS9brCoS8gwZDQqaTp9S4-0qOnOoXBJtksTlkB287bBkzaoNn6vgpADIC6JK4w")
  {:ok,
    %AcmeBank.Accounts.Account{
      current_wallet_cents: 0,
      id: "649848e2-bd9f-4207-b280-fc417479156e",
      inserted_at: ~N[2019-11-11 17:29:25],
      name: "alesshh",
      updated_at: ~N[2019-11-11 17:29:25]
    }
  }
  """
  def verify_token(token) do
    with {:ok, claims} <- AccessToken.decode_and_verify(token),
         {:ok, resource_id} <- AccessToken.resource_from_claims(claims),
         account when not is_nil(account) <- Accounts.get_account(resource_id) do
      {:ok, account}
    else
      _ ->
        {:error, :invalid_access_token}
    end
  end
end
