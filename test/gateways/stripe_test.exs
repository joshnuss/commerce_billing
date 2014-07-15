defmodule Commerce.Billing.Gateways.StripeTest do
  use ExUnit.Case, async: false

  import Mock

  alias Commerce.Billing.CreditCard
  alias Commerce.Billing.Address
  alias Commerce.Billing.Response
  alias Commerce.Billing.Gateways.Stripe, as: Gateway

  defmacrop with_request(url, {status, response}, statement, [do: block]) do
    quote do
      {:ok, agent} = Agent.start_link(fn -> nil end)

      requestFn = fn(:post, unquote(url), params, [{"Content-Type", "application/x-www-form-urlencoded"}], [hackney: [basic_auth: {'user', 'pass'}]]) ->
        Agent.update(agent, fn(_) -> params end)
        %{status_code: unquote(status), body: unquote(response)}
      end

      with_mock HTTPoison, [request: requestFn] do
        unquote(statement)
        var!(params) = Agent.get(agent, &(URI.decode_query(&1)))

        unquote(block)

        Agent.stop(agent)
      end
    end
  end

  setup do
    config = %{credentials: {'user', 'pass'}, default_currency: "USD"}
    {:ok, config: config}
  end

  test "authorize success with credit card", %{config: config} do
    raw = ~S/
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

    with_request "https://api.stripe.com/v1/charges", {200, raw},
        response = Gateway.authorize(10.95, card, address: address, config: config) do

      {:ok, %Response{authorization: authorization, success: success,
                      avs_result: avs_result, cvc_result: cvc_result}} = response

      assert success
      assert params["capture"] == "false"
      assert params["currency"] == "USD"
      assert params["amount"] == "1095"
      assert params["card[name]"] == "John Smith"
      assert params["card[number]"] == "123456"
      assert params["card[exp_month]"] == "11"
      assert params["card[exp_year]"] == "2015"
      assert params["card[cvc]"] == "123"
      assert authorization == "1234"
      assert avs_result == "P"
      assert cvc_result == "M"
    end
  end
end
