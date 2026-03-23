defmodule ItemsApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :items_api,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ItemsApi.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.14"},
      {:bandit, "~> 1.0"},
      {:ecto, "~> 3.11"},
      {:ecto_sqlite3, "~> 0.13"},
      {:jason, "~> 1.4"}
    ]
  end
end
