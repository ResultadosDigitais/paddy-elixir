defmodule Paddy.MixProject do
  use Mix.Project

  def project do
    [
      app: :paddy,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Pubsub integration
      {:google_api_pub_sub, "~> 0.4"},

      # Auth with google cloud platform
      {:goth, "~> 1.0"},

      # Mock dependencies
      {:mock, "~> 0.3", only: :test}
    ]
  end
end
