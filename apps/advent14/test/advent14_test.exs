defmodule Advent14Test do
  use ExUnit.Case
  doctest Advent14

  test "scorer" do
    "data/test2.txt"
    |> File.stream!()
    |> Enum.map(&Advent14.parse_line/1)
    |> Advent14.rotate90_left()
    |> IO.inspect()

    |> Enum.map(&Advent14.score(&1))
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()
  end
end
