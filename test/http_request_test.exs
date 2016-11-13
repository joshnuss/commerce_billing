defmodule Commerce.Billing.HttpRequestTest do
  use ExUnit.Case
  
  alias Commerce.Billing.HttpRequest
  
  test "new should return a new valid HttpRequest struct" do
    request = HttpRequest.new(:post, "http://example.com")
    
    assert request == %HttpRequest {
      method: :post,
      url: "http://example.com",
      headers: []
    }
  end
  
  test "put_body should set the body field using json encoding" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_body(%{test: "value"}, :json)
      
    assert request.headers == [{"Content-Type", "application/json"}]
    assert request.body == "{\"test\":\"value\"}"
  end
  
  test "put_body should set the body field using url encoding encoding" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_body(%{test: "value"}, :url_encoded)
      
    assert request.headers == [{"Content-Type", "application/x-www-form-urlencoded"}]
    assert request.body == "test=value"
  end
  
  test "put_auth should set auth to basic" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_auth(:basic, "user:name")
    
    assert request.auth_mode == :basic
    assert request.credentials == [hackney: [basic_auth: "user:name"]]
  end
  
  test "put_auth should set auth to bearer" do
    request =
      HttpRequest.new(:post, "")
      |> HttpRequest.put_auth(:bearer, "token")
    
    assert request.auth_mode == :bearer
    assert request.headers == [{"Authorization", "bearer token"}]
  end
end