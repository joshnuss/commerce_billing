defmodule Commerce.Billing.Gateways.PaypalTest do
  use ExUnit.Case, async: false
  
  import Mock
  import Commerce.Billing.TestMacros
  
  alias Commerce.Billing.Gateways.Paypal, as: Gateway
  
  @base_url "https://api.sandbox.paypal.com/v1"
  
  setup do
    config = %{credentials: {"user", "pass"}, default_currency: "USD"}
    {:ok, config: config}
  end
  
  test "init should set the access_token", %{config: config} do
    raw = ~S/
      {
        "access_token": "a.token"
      }
    /
    
    with_post "#{@base_url}/oauth2/token", {200, raw},
      result = Gateway.init(config)
    do
      {:ok, config} = result
      
      assert params["grant_type"] == "client_credentials"
      assert config.access_token == "a.token"
    end
  end
end
