defimpl Jason.Encoder, for: AcmeBank.Accounts.Account do
  def encode(value, opts) do
    value
    |> Map.take([:id, :name, :inserted_at, :updated_at])
    |> Jason.Encode.map(opts)
  end
end
