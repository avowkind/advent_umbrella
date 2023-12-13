defmodule Advent12Test do
  use ExUnit.Case
  doctest Advent12

  test "test file" do
    Advent12.parse_file("data/test.txt")
    |> IO.inspect()
  end
end
