defmodule AcmeBank.RepoCase do
  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias AcmeBank.Repo

      import Ecto
      import Ecto.Query
      import AcmeBank.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AcmeBank.Repo)

    unless tags[:async] do
      Sandbox.mode(AcmeBank.Repo, {:shared, self()})
    end

    :ok
  end
end
