defmodule Commerce.Payments.Gateways.Base do
  def http(method, path, params \\ [], opts \\ []) do
    credentials = Keyword.get(opts, :credentials)
    headers     = [{"Content-Type", "application/x-www-form-urlencoded"}]
    data        = params_to_string(params)

    HTTPoison.request(method, path, data, headers, [hackney: [basic_auth: credentials]])  
  end

  def money_to_cents(amount) when is_float(amount) do
    trunc(amount * 100)
  end

  def money_to_cents(amount) do
    amount
  end

  defp params_to_string(params) do
    params |> Enum.filter(fn {_k, v} -> v != nil end)
           |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
           |> Enum.join("&")
  end
end
