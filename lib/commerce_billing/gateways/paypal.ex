defmodule Commerce.Billing.Gateways.Paypal do
  use Commerce.Billing.Gateways.Base
  
  import Poison, only: [decode!: 1]
  
  @base_url "https://api.sandbox.paypal.com/v1"
  
  def init(config) do
    case http(
      :post,
      "#{@base_url}/oauth2/token",
      %{grant_type: "client_credentials"},
      credentials: config.credentials)
    do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          config =
            body
            |> decode!
            |> Map.get("access_token")
            |> put_access_token(config)
        
          {:ok, config}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:stop, "Unexpected #{code} http status code returned requesting access_token"}
      
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:stop, reason}
    end
  end
  
  defp put_access_token(token, config),
    do: Map.put(config, :access_token, token)
end