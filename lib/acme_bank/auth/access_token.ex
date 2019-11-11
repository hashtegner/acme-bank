defmodule AcmeBank.Auth.AccessToken do
  use Guardian, otp_app: :acme_bank

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok, id}
  end
end
