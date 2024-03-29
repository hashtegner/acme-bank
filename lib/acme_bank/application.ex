defmodule AcmeBank.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:acme_bank, :port)

    children = [
      # Starts a worker by calling: AcmeBank.Worker.start_link(arg)
      # {AcmeBank.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: AcmeBank.Api.Router, options: [port: port]},
      AcmeBank.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AcmeBank.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
