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
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 0.5", only: :test},
      {:guardian, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.2.1"},
      {:postgrex, ">= 0.15.1"}
    ]
  end
end
