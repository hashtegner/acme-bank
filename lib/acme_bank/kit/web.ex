defmodule AcmeBank.Kit.Web do
  alias Plug.Conn

  def send_json(conn, status, data) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(status, Jason.encode!(data))
  end
end
