defmodule Commerce.Payments.Gateways.Bogus do
  use Commerce.Payments.Gateways.Base

  alias Commerce.Payments.CreditCard
  alias Commerce.Payments.Address

  def purchase(_amount, _card_or_id, _opts) do
    {:ok, random_string, %{}}
  end

  def authorize(_amount, _card_or_id, _opts) do
    {:ok, random_string, %{}}
  end

  def capture(id, _opts) do
    {:ok, id, %{}}
  end

  def void(id, _opts) do
    {:ok, id, %{}}
  end

  def refund(amount, id, opts) do
    {:ok, id, %{}}
  end

  def store(_card=%CreditCard{}, _opts) do
    {:ok, random_string, %{}}
  end

  def unstore(customer_id, nil, _opts) do
    {:ok, customer_id, %{}}
  end

  def unstore(_customer_id, card_id, _opts) do
    {:ok, card_id, %{}}
  end

  defp random_string(length \\ 10) do
    1..length |> Enum.map(fn _ -> to_string(:crypto.rand_uniform(0,9)) end) |> Enum.join
  end
end
