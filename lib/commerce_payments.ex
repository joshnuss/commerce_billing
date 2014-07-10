defmodule Commerce.Payments do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Commerce.Payments.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Commerce.Payments.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def authorize(worker, amount, card, opts \\ []) do
    GenServer.call(worker, {:authorize, amount, card, opts})
  end

  def purchase(worker, amount, card, opts \\ []) do
    GenServer.call(worker, {:purchase, amount, card, opts})
  end
end
