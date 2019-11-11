defmodule AcmeBank.Api.Auth do
  import Plug.Conn

  @auth_service Application.get_env(:acme_bank, :auth_service)

  def init(opts), do: opts

  def call(conn, _opts) do
    with access_token <- fetch_token_from_header(conn),
         {:ok, account} <- @auth_service.verify_token(access_token) do
      assign(conn, :current_account, account)
    else
      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  defp fetch_token_from_header(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
    |> to_string()
    |> String.replace_prefix("Bearer", "")
    |> String.trim()
  end
end
