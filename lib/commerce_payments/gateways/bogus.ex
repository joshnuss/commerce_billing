defmodule Commerce.Payments.Gateways.Bogus do
  use Commerce.Payments.Gateways.Base

  alias Commerce.Payments.CreditCard

  def purchase(_amount, _card_or_id, _opts) do
    success
  end

  def authorize(_amount, _card_or_id, _opts) do
    success
  end

  def capture(id, _opts) do
    success(id)
  end

  def void(id, _opts) do
    success(id)
  end

  def refund(_amount, id, _opts) do
    success(id)
  end

  def store(_card=%CreditCard{}, _opts) do
    success
  end

  def unstore(customer_id, nil, _opts) do
    success(customer_id)
  end

  def unstore(_customer_id, card_id, _opts) do
    success(card_id)
  end

  defp success do
    {:ok, random_string, %{}}
  end

  defp success(id) do
    {:ok, id, %{}}
  end

  defp random_string(length \\ 10) do
    1..length |> Enum.map(fn _ -> to_string(:crypto.rand_uniform(0,9)) end) |> Enum.join
  end
end
