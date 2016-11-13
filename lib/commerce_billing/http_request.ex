defmodule Commerce.Billing.HttpRequest do
  defstruct [:method, :url, :headers, :body, :auth_mode, :credentials]
  
  alias Poison
  alias Commerce.Billing.HttpRequest
  
  def new(method, url) do
    %HttpRequest{
      method: method,
      url: url,
      headers: [],
      auth_mode: :none
    }
  end
  
  def put_body(request, params, encoding) do
    con_type = content_type(encoding)
    
    request
      |> Map.put(:body, encode_body(encoding, params))
      |> put_header(con_type)
  end
  
  def put_auth(request, :basic, credentials) do
    request
      |> Map.put(:auth_mode, :basic)
      |> Map.put(:credentials, [hackney: [basic_auth: credentials]])
  end
  
  def put_auth(request, :bearer, token) do
    request
      |> Map.put(:auth_mode, :bearer)
      |> put_header({"Authorization", "bearer #{token}"})
  end
  
  def send(request = %{auth_mode: :basic}) do
    HTTPoison.request(
      request.method,
      request.url,
      request.body,
      request.headers,
      request.credentials)
  end
  
  def send(request) do
    HTTPoison.request(
      request.method,
      request.url,
      request.body,
      request.headers)
  end
  
  defp put_header(request, header),
    do: Map.put(request, :headers, [header | request.headers])
  
  defp content_type(:url_encoded),
    do: {"Content-Type", "application/x-www-form-urlencoded"}
    
  defp content_type(:json),
    do: {"Content-Type", "application/json"}
    
  defp encode_body(:url_encoded, params) do
    params
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> URI.encode_query
  end
  
  defp encode_body(:json, params),
    do: Poison.encode!(params)
  
  defp encode_body(_, params),
    do: params
end