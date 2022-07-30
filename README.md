# `Sanity.Components`

[![Package](https://img.shields.io/hexpm/v/sanity_components.svg)](https://hex.pm/packages/sanity_components) [![Documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/sanity_components) ![CI](https://github.com/balexand/sanity_components/actions/workflows/elixir.yml/badge.svg)

Phoenix components for rendering Sanity CMS data, including portable text and images.

## Installation

The package can be installed by adding `sanity_components` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sanity_components, "~> 0.3.0"}
  ]
end
```

## Usage

Start by fetching data from Sanity CMS using the [`sanity` client library](https://github.com/balexand/sanity). Components in this package expect map keys to be atoms in `underscore_case`.

See docs for:

* [Rendering portable text](https://hexdocs.pm/sanity_components/Sanity.Components.PortableText.html)
* [Rendering sanity images](https://hexdocs.pm/sanity_components/Sanity.Components.Image.html)
