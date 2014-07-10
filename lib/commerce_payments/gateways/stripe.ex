defmodule Commerce.Payments.Gateways.Stripe do
  @base_url "https://api.stripe.com/v1"

  import Commerce.Payments.Gateways.Base
  alias Commerce.Payments.CreditCard
  alias Commerce.Payments.Address

  def purchase(amount, card_or_id, opts) do
    authorize(amount, card_or_id, [{:capture, true} | opts])
  end

  def authorize(amount, card_or_id, opts) do
    config      = Keyword.fetch!(opts, :config)
    description = Keyword.get(opts, :description)
    address     = Keyword.get(opts, :billing_address)
    customer_id = Keyword.get(opts, :customer_id)
    currency    = Keyword.get(opts, :currency, config.default_currency)
    capture     = Keyword.get(opts, :capture, false)

    params = [capture: capture, description: description,
              currency: currency, customer: customer_id] ++
             amount_params(amount) ++
             card_params(card_or_id) ++
             address_params(address)

    commit(:post, "charges", params, opts)
  end

  def capture(id, opts) do
    amount = Keyword.get(opts, :amount)

    params = amount_params(amount)

    commit(:post, "charges/#{id}/capture", params, opts)
  end

  def void(id, opts) do
    commit(:post, "charges/#{id}/refund", opts)
  end

  def refund(amount, id, opts) do
    params = amount_params(amount)

    commit(:post, "charges/#{id}/refund", params, opts)
  end
  
  def store(card=%CreditCard{}, opts) do
    customer_id = Keyword.get(opts, :customer_id)
    params = card_params(card)

    path = if customer_id, do: "customers/#{customer_id}/card", else: "customers"

    commit(:post, path, params, opts)
  end

  def unstore(customer_id, opts) do
    commit(:delete, "customers/#{customer_id}", [], opts)
  end

  def unstore(customer_id, card_id, opts) do
    commit(:delete, "customers/#{customer_id}/#{card_id}", [], opts)
  end

  defp amount_params(amount) do
    [amount: money_to_cents(amount)]
  end

  defp card_params(card=%CreditCard{}) do
    {expiration_year, expiration_month} = card.expiration

    ["card[number]":    card.number,
     "card[exp_year]":  expiration_year,
     "card[exp_month]": expiration_month,
     "card[cvc]":       card.cvc,
     "card[name]":      card.name]
  end

  defp card_params(id), do: [card: id]

  defp address_params(address=%Address{}) do
    ["card[address_line1]": address.street1,
     "card[address_line2]": address.street2,
     "card[address_city]":  address.city,
     "card[address_state]": address.region,
     "card[address_zip]":   address.postal_code,
     "card[address_country]": address.country]
  end

  defp address_params(_), do: []

  defp commit(method, path, params \\ [], opts \\ []) do
    config = Keyword.fetch!(opts, :config)
    http(method, "#{@base_url}/#{path}", params, credentials: config.credentials)
    |> respond
  end

  defp respond(%{status_code: 200, body: body}) do
    data = Jazz.decode!(body)
    {:ok, data["id"], data}
  end

  defp respond(%{body: body}) do
    data = Jazz.decode!(body)
    {:error, error(data["error"]), data}
  end

  defp error(%{"type" => "invalid_request_error"}), do: :invalid_request
  defp error(%{"code" => "incorrect_number"}),      do: {:declined, :invalid_number}
  defp error(%{"code" => "invalid_expiry_year"}),   do: {:declined, :invalid_expiration}
  defp error(%{"code" => "invalid_expiry_month"}),  do: {:declined, :invalid_expiration}
  defp error(%{"code" => "invalid_cvc"}),           do: {:declined, :invalid_cvc}
  defp error(_), do: :unknown
end
