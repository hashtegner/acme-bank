defmodule AcmeBankTest do
  use ExUnit.Case
  doctest AcmeBank

  test "greets the world" do
    assert AcmeBank.hello() == :world
  end
end
