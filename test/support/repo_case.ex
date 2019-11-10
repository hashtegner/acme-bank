defmodule AcmeBank.RepoCase do
  use ExUnit.CaseTemplate

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
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AcmeBank.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AcmeBank.Repo, {:shared, self()})
    end

    :ok
  end
end
