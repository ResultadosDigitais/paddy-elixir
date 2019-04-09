defmodule PaddyTest do
  use ExUnit.Case
  doctest Paddy

  test "greets the world" do
    assert Paddy.hello() == :world
  end
end
