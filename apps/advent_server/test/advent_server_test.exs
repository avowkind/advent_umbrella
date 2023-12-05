defmodule AdventServerTest do
  use ExUnit.Case
  doctest AdventServer

  test "greets the world" do
    assert AdventServer.hello() == :world
  end
end
