defmodule AcmeBank.Api.Health do
  alias AcmeBank.Kit.Web

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> Web.send_json(200, %{alive: true})
  end
end
