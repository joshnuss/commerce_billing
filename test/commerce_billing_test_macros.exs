defmodule Commerce.Billing.TestMacros do
  defmacro with_post(url, {status, response}, statement, do: block) do
    quote do
      {:ok, agent} = Agent.start_link(fn -> nil end)
  
      requestFn = fn(:post, unquote(url), params, [{"Content-Type", "application/x-www-form-urlencoded"}], [hackney: [basic_auth: {"user", "pass"}]]) ->
        Agent.update(agent, fn(_) -> params end)
        {:ok, %HTTPoison.Response{status_code: unquote(status), body: unquote(response)}}
      end
  
      with_mock HTTPoison, [request: requestFn] do
        unquote(statement)
        var!(params) = Agent.get(agent, &(URI.decode_query(&1)))
  
        unquote(block)
  
        Agent.stop(agent)
      end
    end
  end
  
  defmacro with_delete(url, {status, response}, do: block) do
    quote do
      requestFn = fn(:delete, unquote(url), params, [{"Content-Type", "application/x-www-form-urlencoded"}], [hackney: [basic_auth: {"user", "pass"}]]) ->
        {:ok, %{status_code: unquote(status), body: unquote(response)}}
      end
  
      with_mock HTTPoison, [request: requestFn], do: unquote(block)
    end
  end
end