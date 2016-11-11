defmodule Commerce.Billing.Gateways.Bogus do
  use Commerce.Billing.Gateways.Base

  alias Commerce.Billing.{
    CreditCard,
    Response
  }
  
  def init(config),
    do: config

  def authorize(_amount, _card_or_id, _opts),
    do: success

  def purchase(_amount, _card_or_id, _opts),
    do: success

  def capture(id, _opts),
    do: success(id)

  def void(id, _opts),
    do: success(id)

  def refund(_amount, id, _opts),
    do: success(id)

  def store(_card=%CreditCard{}, _opts),
    do: success

  def unstore(customer_id, nil, _opts),
    do: success(customer_id)

  def unstore(_customer_id, card_id, _opts),
    do: success(card_id)

  defp success,
    do: {:ok, Response.success(authorization: random_string)}

  defp success(id),
    do: {:ok, Response.success(authorization: id)}

  defp random_string(length \\ 10),
    do: 1..length |> Enum.map(&random_char/1) |> Enum.join

  defp random_char(_),
    do: to_string(:crypto.rand_uniform(0,9))
end
