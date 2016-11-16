defmodule Commerce.Billing.Gateways.Base do
  alias Commerce.Billing.Response

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      def purchase(_amount, _card_or_id, _opts)  do
        not_implemented
      end

      def authorize(_amount, _card_or_id, _opts)  do
        not_implemented
      end

      def capture(_id, _opts) do
        not_implemented
      end

      def void(_id, _opts) do
        not_implemented
      end

      def refund(_amount, _id, _opts) do
        not_implemented
      end

      def store(_card, _opts) do
        not_implemented
      end

      def unstore(_customer_id, _card_id, _opts) do
        not_implemented
      end
      
      defp money_to_cents(amount) when is_float(amount) do
        trunc(amount * 100)
      end

      defp money_to_cents(amount) do
        amount
      end

      @doc false
      defp not_implemented do
        {:error, Response.error(code: :not_implemented)}
      end

      defoverridable [purchase: 3, authorize: 3, capture: 2, void: 2, refund: 3, store: 2, unstore: 3]
    end
  end
end
