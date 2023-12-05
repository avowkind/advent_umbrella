defmodule Advent3Test do
  use ExUnit.Case
  doctest Advent3

  @lines """
..........
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"""

@table [
  {[], []},
  {[{467, {-1, 3}}, {114, {4, 8}}], []},
  {[], [3]},
  {[{35, {1, 4}}, {633, {5, 9}}], []},
  {[], [6]},
  {[{617, {-1, 3}}], [3]},
  {[{58, {6, 9}}], [5]},
  {[{592, {1, 5}}], []},
  {[{755, {5, 9}}], []},
  {[], [3, 5]},
  {[{664, {0, 4}}, {598, {4, 8}}], []},
  {[], []}
]
  test "readlines" do
    assert Advent3.readlines(@lines) == @table
  end

  test "is_engine_part_row" do
    number = {467, {-1, 3}}
    assert Advent3.is_engine_part_row?(number, {[], []}) == false
    assert Advent3.is_engine_part_row?(number,  {[], [3]}) == true
    assert Advent3.is_engine_part_row?({617, {-1, 3}},  {[{617, {-1, 3}}], [3]}) == true
  end

  test "is_engine_part" do
    [chunk1 | tl] = Enum.chunk_every(@table, 3,1)
    assert Advent3.is_engine_part?({467, {-1, 3}}, chunk1) == true
    assert Advent3.is_engine_part?({114, {4, 8}}, chunk1) == false
    [chunk2 | tl] = tl
    assert Advent3.is_engine_part?({35, {1, 4}}, chunk2) == true
    assert Advent3.is_engine_part?({633, {5, 9}}, chunk2) == false
    [chunk3 | _] = tl
    assert Advent3.is_engine_part?({633, {5, 9}}, chunk3) == true

  end

  test "sum_row" do
    [chunk1 | _] = Enum.chunk_every(@table, 3,1)
    [ _, current, _] = chunk1
    assert Advent3.sum_row(current, chunk1) == 467
  end

  test "accumulate_scores" do
    assert Advent3.accumulate_scores(@table) == [467, 0, 668, 0, 617, 0, 592, 755, 0, 1262]
  end

  test "run_str" do
    assert Advent3.run_str(@lines) ==  4361
  end

  test "run_file" do
    assert Advent3.run_file() ==  498559
  end

  test "get_asterisk_positions" do
    assert Advent3.get_asterisk_positions(".*35#$%^*.633.") == [1, 8]
  end

  @doc """
..........
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"""
  test "stars_in_row" do
    lines = @lines
      |> String.split("\n")
      |> Enum.map(&Advent3.parse_line_2(&1))
    [chunk1 | tl ] = Enum.chunk_every(lines, 3,1)
    [ _, current, _] = chunk1
    assert Advent3.stars_in_row(current, chunk1) == [] # no stars
    [ chunk2 | tl ] = tl
    [ _, current, _] = chunk2
    assert Advent3.stars_in_row(current, chunk2) == [16345]
    [ chunk3 | _ ] = tl
    [ _, current, _] = chunk3
    assert Advent3.stars_in_row(current, chunk3) == []
  end

  test "accumulate_gears" do
    lines = @lines
    |> String.split("\n")
    |> Enum.map(&Advent3.parse_line_2(&1))
    assert Advent3.accumulate_gears(lines) == [[], [16345], [], [], [0], [], [], [], [451490], []]
  end
  test "gear_ratios" do
    assert Advent3.gear_ratios() ==  72246648  # correct
  end
end
