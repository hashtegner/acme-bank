defmodule AcmeBank.Kit.Plug do
  defmacro __using__(_) do
    quote do
      use Plug.Router

      if Mix.env() == :dev do
        use Plug.Debugger, otp_app: :acme_bank_api
      else
        use Plug.ErrorHandler
      end

      if Mix.env() != :test do
        plug(Plug.Logger)
      end

      plug(Plug.RequestId)
      plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
    end
  end
end
