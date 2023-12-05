defmodule Advent3 do
  @moduledoc """
  Documentation for `Advent3`.
  Engine Schematic processor

  find engine parts maked by symbols,
  either find symbols and track adjacent numbers
  or find numbers and track adjacent symbols

  easy to find numbers. length may be 1 to 3 digits

  if symbol is on row above or below including diagonally
  e.g  *****
       *123*
       *****
  any of the marked positions. 123 is engine part

  at any time track 3 strings or char arrays
  -1 above
  0 current
  1 below

  find number - get index positions [a,b,c]
  check -1 positions a-1, a, b, c, c+1
  check 0 positions a-1, c+1
  check 1 positions a-1, a, b, c, c+1

  repeat for other numbers in the row

  then pop current row and append new row.
  init with row of dots, end with row of dots.

  we need to sum all engine parts. so push each value to a list ( or just accumulate sum)

  467..114..
  ...*......

  convert the digits to start and length of number
  convert length to end position
  compare to symbol positions
  if symbol position is in range of number, then number is engine part
  schematic is 140x140

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

  @doc """
  split a line to find its numbers and their min/max positions

  ## Examples
    iex> Advent3.get_number_positions_and_values("..35..633.")
    [
      {35, {1, 4}},
      {633, {5, 9}}
    ]

  """
  def get_number_positions_and_values(line) do
    # convert a tuple of start and length to a tuple of start and end
    to_range = fn { start, length } -> { start-1, start+length } end

    # get a list of numbers from the line by regex
    numbers = Regex.scan(~r/\d+/, line)
      |> Enum.map(fn x -> x |> hd |> String.to_integer() end )
    number_ranges = Regex.scan(~r/\d+/, line, return: :index)
      |> Enum.map(
        fn x -> x |> hd |> to_range.()
        end )

    Enum.zip(numbers, number_ranges)
  end

  @doc """
  split a line to find its symbol positions

  ## Examples
    iex> Advent3.get_symbol_positions(".*35$.633.")
    [ 1, 4 ]

  """
  def get_symbol_positions(line) do
    # get a list of symbols from the line by regex
    Regex.scan(~r/[^0-9a-zA-Z\.]/, line, return: :index)
      |> Enum.map(fn [ { x, _} | _] -> x  end )
  end



  # def is_engine_part?(number, chunk) when number == [] do
  #   false
  # end

  def is_engine_part_row?({ _, { start, finish }}, { _, symbol_positions }) do
    Enum.any?(symbol_positions,
      fn symbol_position ->
        start <= symbol_position and symbol_position <= finish
      end)
  end

  def is_engine_part?(number, chunk) do
    chunk |> Enum.any?(&is_engine_part_row?(number, &1))
  end

  def sum_row({ numbers, _ }, _) when numbers == [] do
    0
  end

  def sum_row({ numbers, _ }, chunk) do
    numbers |> Enum.reduce( 0,
      fn (number, acc) ->
        { value, _ } = number
        acc + if is_engine_part?(number, chunk), do: value, else: 0
      end)
  end

  def accumulate_scores(schematic) do
    # take lines from schematic in groups of 3. 1 above, 1 current, 1 below
    Enum.chunk_every( schematic, 3, 1, :discard)
    |> Enum.map(
      fn chunk ->
        [ _, current, _ ] = chunk
        sum_row(current, chunk)
      end)
  end

  # def accumulate_ratios(schematic) do
  #   # take lines from schematic in groups of 3. 1 above, 1 current, 1 below
  #   Enum.chunk_every( schematic, 3, 1, :discard)
  #   |> Enum.map(
  #     fn chunk ->
  #       [ _, current, _ ] = chunk
  #       sum_row(current, chunk)
  #     end)
  # end
  @doc """
  split a line to find its symbol positions

  """
  def readlines(lines) do
    lines
    |> String.split("\n")
    |> Enum.map(
      fn line ->
        { get_number_positions_and_values(line), get_symbol_positions(line) }
      end)
    # stick a blank line on top of
  end

  def run_str(lines) do
    readlines(lines)
    |> accumulate_scores()
    |> Enum.sum()
  end

  def parse_line(line) do
    line = String.trim(line)
    { get_number_positions_and_values(line), get_symbol_positions(line) }
  end

  def run_file() do
    lines = File.stream!("data/data.txt")
      |> Enum.map(&parse_line(&1))
    # stick a blank line on top of lines
    lines = [ { [], [] } ] ++ lines ++ [ { [], [] } ]
    # IO.inspect(lines)
    lines |> accumulate_scores() |> Enum.sum()

  end

  # part 2

  def get_asterisk_positions(line) do
    # get a list of symbols from the line by regex
    Regex.scan(~r/\*/, line, return: :index)
      |> Enum.map(fn [ { x, _} | _] -> x  end )
  end

  def parse_line_2(line) do
    line = String.trim(line)
    { get_number_positions_and_values(line), get_asterisk_positions(line) }
  end

  def num_in_row({ numbers, _ }, chunk) do
    Enum.filter(numbers, fn number -> is_engine_part?(number, chunk)end)
    |> Enum.map(fn { value, _ } -> { value }  end)
  end

  def resolve_stars(stars) do
    flattened_stars = List.flatten(stars)
    res = case length(flattened_stars) do
      2 -> IO.inspect(flattened_stars); Enum.product(flattened_stars)
      _ -> 0
    end
    IO.inspect(flattened_stars)
    IO.inspect(res)
  end
@doc """
when we process a row it may have no stars - return []
if it has a star the numbers will be above and below, or side by side.
"""

  def stars_in_row({ _, stars }, chunk) do
    Enum.map(stars, fn star ->
      # for each * in the row, find any adjacent numbers
      chunk |> Enum.map(
      fn row ->
        { numbers, _ } = row
        numbers
        |> Enum.filter(fn number ->
          { _, { start, finish } } = number
          start <= star and star <= finish
        end)
        |> Enum.map(fn { value, _ } -> value  end)
      end)
    end)
    |> Enum.map(&resolve_stars(&1))
    # |> IO.inspect()
  end

  def accumulate_gears(schematic) do
    # take lines from schematic in groups of 3. 1 above, 1 current, 1 below
    Enum.chunk_every( schematic, 3, 1, :discard)
    |> Enum.map(
      fn chunk ->
        [ _, current, _ ] = chunk
        stars_in_row(current, chunk)
      end)
  end

  def gear_ratios() do
    lines = File.stream!("data/data.txt")
      |> Enum.map(&parse_line_2(&1))
    # stick a blank line on top of lines
    lines = [ { [], [] } ] ++ lines ++ [ { [], [] } ]

    lines |> accumulate_gears()
    |> List.flatten()
    |> IO.inspect()
    |> Enum.sum()

  end
end
