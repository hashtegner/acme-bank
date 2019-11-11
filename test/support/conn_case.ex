defmodule AcmeBank.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: true
      use Plug.Test

      import Mox

      setup :verify_on_exit!
    end
  end
end
