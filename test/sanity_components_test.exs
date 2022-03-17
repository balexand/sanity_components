defmodule SanityComponentsTest do
  use ExUnit.Case
  doctest SanityComponents

  test "greets the world" do
    assert SanityComponents.hello() == :world
  end
end
