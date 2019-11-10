defmodule AcmeBank.MixProject do
  use Mix.Project

  def project do
    [
      app: :acme_bank,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AcmeBank.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ecto_sql, "~> 3.2.1"},
      {:postgrex, ">= 0.15.1"}
    ]
  end
end
