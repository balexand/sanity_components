defmodule Sanity.Components.MixProject do
  use Mix.Project

  @version "0.14.0"

  def project do
    [
      app: :sanity_components,
      description:
        "Phoenix components for rendering Sanity CMS data, including portable text and images.",
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/balexand/sanity_components"}
      ],
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/balexand/sanity_components"
      ]
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
      # TODO bump version after 1.0 release
      {:phoenix_live_view, "~> 1.0.0-rc.7 or ~> 1.0.0"},

      # dev/test
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
