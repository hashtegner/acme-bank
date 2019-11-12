defimpl Jason.Encoder, for: AcmeBank.Wallet.Transaction do
  def encode(value, opts) do
    value
    |> Map.take([:id, :amount_cents, :account_id, :type, :inserted_at, :updated_at])
    |> Jason.Encode.map(opts)
  end
end
