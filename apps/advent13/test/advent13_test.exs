defmodule Advent13Test do
  use ExUnit.Case
  doctest Advent13

  test "parse_file" do
    assert Advent13.parse_file("data/test.txt") == 400
  end

end
