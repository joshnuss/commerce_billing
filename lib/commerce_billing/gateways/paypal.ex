defmodule Commerce.Billing.Gateways.Paypal do
  use Commerce.Billing.Gateways.Base
  
  import Poison, only: [decode!: 1]
  
  alias Commerce.Billing.HttpRequest
  
  # TODO: add live url support - pointless without it :)
  @base_url "https://api.sandbox.paypal.com/v1"
  
  def init(config) do
    body = %{grant_type: "client_credentials"}
    
    request =
      HttpRequest.new(:post, "#{@base_url}/oauth2/token")
      |> HttpRequest.put_body(body, :url_encoded)
      |> HttpRequest.put_auth(:basic, config.credentials)
      
    case HttpRequest.send(request) do
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