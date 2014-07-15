defmodule Commerce.Billing.Gateways.StripeTest do
  use ExUnit.Case, async: false

  import Mock

  alias Commerce.Billing.CreditCard
  alias Commerce.Billing.Address
  alias Commerce.Billing.Response
  alias Commerce.Billing.Gateways.Stripe, as: Gateway

  defmacrop with_request(url, params, status, response, [do: block]) do
    quote do
      requestFn = fn(:post, unquote(url), unquote(params), [{"Content-Type", "application/x-www-form-urlencoded"}], [hackney: [basic_auth: {'user', 'pass'}]]) ->
        %{status_code: unquote(status), body: unquote(response)}
      end
      with_mock HTTPoison, [request: requestFn], do: unquote(block)
    end
  end

  setup do
    config = %{credentials: {'user', 'pass'}, default_currency: "USD"}
    {:ok, config: config}
  end

  test "authorize success with credit card", %{config: config} do
    response = ~S/
      {
        "id": "1234",
        "card": {
          "cvc_check": "pass",
          "address_line1_check": "unchecked",
          "address_zip_check": "pass"
        }
      }
    /
    card = %CreditCard{name: "John Smith", number: "123456", cvc: "123", expiration: {2015, 11}}
    address = %Address{}

    with_request "https://api.stripe.com/v1/charges", "capture=false&currency=USD&amount=1095&card%5Bnumber%5D=123456&card%5Bexp_year%5D=2015&card%5Bexp_month%5D=11&card%5Bcvc%5D=123&card%5Bname%5D=John+Smith", 200, response do
      {:ok, %Response{authorization: authorization,
                success: success,
                avs_result: avs_result,
                cvc_result: cvc_result}} = Gateway.authorize(10.95, card, address: address, config: config)

      assert success
      assert authorization == "1234"
      assert avs_result == "P"
      assert cvc_result == "M"
    end
  end
end
