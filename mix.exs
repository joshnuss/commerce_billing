defmodule Commerce.Billing.Mixfile do
  use Mix.Project

  def project do
    [app: :commerce_billing,
     version: "0.0.1",
     elixir: "~> 0.14.2",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:httpoison],
     mod: {Commerce.Billing, []}]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:jazz, "~> 0.1.2"},
     {:httpoison, "~> 0.3.0"},
     {:hackney, github: "benoitc/hackney"},
     {:ex_doc, github: "elixir-lang/ex_doc"}]
  end
end
