defmodule Advent9 do
  @moduledoc """
  Advent of Code 2023, Day 9 Mirage Maintenance

  Read a line of numbers, find the differences between each pair of numbers.
  Repeat until all the differences are 0.
  find the next number in the sequence.  Sum the set of next numbers.
  part 2 find the previous number in the sequence.
  """


  @doc """
  Parsing
  read each line into a number array.

  Example:

          iex> Advent9.parse_line("1 2  3")
          [1, 2, 3]
  """
  def parse_line(line) do
    line
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  read all the lines in the file into a list of number arrays.

  Example:

          iex> Advent9.parse_lines("data/test.txt")
          [[0, 3, 6, 9, 12, 15], [1, 3, 6, 10, 15, 21], [10, 13, 16, 21, 30, 45]]
  """
  def parse_lines(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
  end

  @doc """
  process an integer array into a list of differences

  Example:

          iex> Advent9.diffs([1, 3, 5, 7, 9])
          [2,2,2,2]

          iex> Advent9.diffs([1,2,3,5,8,13,21,34,55,89])
          [1,1,2,3,5,8,13,21,34]

  """
  def diffs(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end


  @doc """

  repeat diffs pushing the last value into the accumulator
  until we get to 0,0,0...
  then sum the accumulator

  Example:

          iex> Advent9.next_in_sequence({[1,   3,   6,  10,  15,  21],0})
          28
  """

  def next_in_sequence({list, acc} ) do
    ## get the last item and add it into the accumulator
    acc = acc + List.last(list)

    # calc the diffs
    new_list = diffs(list)
    if Enum.all?(new_list, &(&1 == 0)) do
      acc
    else
      next_in_sequence({new_list, acc})
    end
  end

  @doc """

  Example:

          iex> Advent9.part1_test()
          114
  """
  def part1_test do
    parse_lines("data/test.txt")
    |> Enum.map(&next_in_sequence({&1, 0}))
    |> Enum.sum()
    |> IO.inspect()
  end

  # def part1 do
  #   parse_lines("data/data.txt")
  #   |> Enum.map(&next_in_sequence({&1, 0}))
  #   |> IO.inspect()
  #   |> Enum.sum()
  #   |> IO.inspect()
  # end


  defp r_prev_next_in_sequence({list, acc} ) do

    # IO.inspect(list)
    { first, last, i } = acc
    acc = { first + i* List.first(list), last + List.last(list), i*-1 }

    # calc the diffs
    new_list = diffs(list)
    if Enum.all?(new_list, &(&1 == 0)) do
      acc
    else
      r_prev_next_in_sequence({new_list, acc})
    end
  end

  @doc """
  Calculates both the next and previous values in the sequence
  repeat diffs pushing the first and last value into the accumulator
  until we get to 0,0,0...
  then sum the accumulator,
  summing the previous is multiplied by alternating +1 and -1 to get the correct effect

  Example:

          iex> Advent9.prev_next_in_sequence([10,  13, 16,  21,  30,  45])
          {5, 68}

          iex>  Advent9.prev_next_in_sequence([1, 3, 6, 10, 15, 21])
          {0, 28}
  """

  def prev_next_in_sequence( list ) do
    { a,b,_} = r_prev_next_in_sequence({list, {0,0,1}})
    { a, b }
  end

  @doc """
  Run the part 2 prev and next algorithm on the test data
  Example:

          iex> Advent9.part2_test()
          {2, 114}
  """
  def part2_test do
    parse_lines("data/test.txt")
    |> Enum.map(&prev_next_in_sequence(&1))
    |> Enum.reduce({0,0}, fn {a,b}, {c,d} -> {a+c, b+d} end)
    |> IO.inspect()
  end

  @doc """
  Run the part 2 prev and next algorithm on the real data
  Example:

          iex> Advent9.part2_real()
          {975, 1641934234}
  """
  def part2_real do
    parse_lines("data/data.txt")
    |> Enum.map(&prev_next_in_sequence(&1))
    |> Enum.reduce({0,0}, fn {a,b}, {c,d} -> {a+c, b+d} end)
    |> IO.inspect()
  end
end
