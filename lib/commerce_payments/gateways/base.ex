defmodule Commerce.Payments.Gateways.Base do
  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      def purchase(_amount, _card_or_id, _opts)  do
        {:error, :not_implemented, nil}
      end

      def authorize(_amount, _card_or_id, _opts)  do
        {:error, :not_implemented, nil}
      end

      def capture(_id, _opts) do
        {:error, :not_implemented, nil}
      end

      def void(_id, _opts) do
        {:error, :not_implemented, nil}
      end

      def refund(_amount, _id, _opts) do
        {:error, :not_implemented, nil}
      end

      def store(_card, _opts) do
        {:error, :not_implemented, nil}
      end

      def unstore(_customer_id, _card_id, _opts) do
        {:error, :not_implemented, nil}
      end

      defp http(method, path, params \\ [], opts \\ []) do
        credentials = Keyword.get(opts, :credentials)
        headers     = [{"Content-Type", "application/x-www-form-urlencoded"}]
        data        = params_to_string(params)

        HTTPoison.request(method, path, data, headers, [hackney: [basic_auth: credentials]])
      end

      defp money_to_cents(amount) when is_float(amount) do
        trunc(amount * 100)
      end

      defp money_to_cents(amount) do
        amount
      end

      defp params_to_string(params) do
        params |> Enum.filter(fn {_k, v} -> v != nil end)
               |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
               |> Enum.join("&")
      end

      defoverridable [purchase: 3, authorize: 3, capture: 2, void: 2, refund: 3, store: 2, unstore: 3]
    end
  end

end
