defmodule AcmeBank.Kit.Changeset do
  alias Ecto.Changeset

  @typedoc """
  Changeset traversed errors, compatible with poison encoder
  """
  @type errors :: %{atom => [%{msg: String.t(), atom: %{atom => atom}}]}

  @doc ~S"""
  Traverse changeset errors

  ## Examples
    iex> traverse_errors(changeset)
    %{name: [%{msg: "is required", rules: %{validation: :required}}]}
  """

  @spec traverse_errors(Ecto.Changeset.t()) :: errors
  def(traverse_errors(changeset)) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      msg =
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)

      %{msg: msg, rules: Map.new(opts)}
    end)
  end
end
