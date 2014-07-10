defmodule Commerce.Billing do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Commerce.Billing.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Commerce.Billing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def authorize(worker, amount, card, opts \\ []) do
    GenServer.call(worker, {:authorize, amount, card, opts})
  end

  def purchase(worker, amount, card, opts \\ []) do
    GenServer.call(worker, {:purchase, amount, card, opts})
  end

  def capture(worker, id, opts \\ []) do
    GenServer.call(worker, {:capture, id, opts})
  end

  def void(worker, id, opts \\ []) do
    GenServer.call(worker, {:void, id, opts})
  end

  def refund(worker, amount, id, opts \\ []) do
    GenServer.call(worker, {:refund, amount, id, opts})
  end

  def store(worker, card, opts \\ []) do
    GenServer.call(worker, {:store, card, opts})
  end

  def unstore(worker, customer_id, card_id = nil, opts \\ []) do
    GenServer.call(worker, {:unstore, customer_id, card_id, opts})
  end
end
