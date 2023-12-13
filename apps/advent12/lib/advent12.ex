defmodule Advent12 do
  @moduledoc """
  Documentation for `Advent12`.
  """

  @doc """
  Parsing
  read each line into a number array.

  Example:

          iex> Advent12.parse_line("???.### 1,1,3")
          {["???", "###"], [1, 1, 3]}
  """
  def parse_line(line) do
    [code, points] = line
    |> String.trim()
    |> String.split(" ")

    code = code |> String.split(".", trim: true)
    points = points |> String.split(",") |> Enum.map(&String.to_integer/1)
    { code, points}
  end


  @doc """
  given a tuple {pos,slots} return the number of positions in the slots
  by sliding the pos over the slots
  Example

            iex> Advent12.positions_in_slots({1,1})
            1
            iex> Advent12.positions_in_slots({1,5})
            5
            iex> Advent12.positions_in_slots({2,5})
            6
            iex> Advent12.positions_in_slots({3,7})
            10
            iex> Advent12.positions_in_slots({4,8})
            5
            iex> Advent12.positions_in_slots({4,7})
            1
  """
  def positions_in_slots({pos, width}) do
    # if pos > 1 then we must leave a space between each pick
    # so we have to subtract pos - 1 from the width
    Math.k_combinations(width - (pos-1),pos)
  end

  @doc """
  given a tuple {pos,slots} return the number of strips fit in the slots
    # if array is the widths of the strips
    # [ 2,3,1,1 ]  then reduce the width by the sum - the count
    e.g width = 7 - 4
  Example:
          iex> Advent12.strips_in_slots({[1,1], 5})
          6
          iex> Advent12.strips_in_slots({[2,1], 7})
          10
  """
  def strips_in_slots({arr, width}) do
    choices = Enum.count(arr)
    width = width - (Enum.sum(arr) - choices)
    positions_in_slots({choices, width})
  end


  @doc """
  For each pair we can calculate the number of positions

  Example:
          iex> Advent12.calc_groups(  [{"??",[1]}, {"??",[1]}] )
          [2,2]
          iex> Advent12.calc_groups(  [{"???",[1]}, {"????",[2]}] )
          [3,3]

          iex> Advent12.calc_groups(  [{"???",[3]}, {"????",[2,1]}] )
          [1,1]
          iex> Advent12.calc_groups(  [{"????????",[3,2,1]}] )
          [1]
  """
  def calc_groups(list) do
    list |> Enum.map(
      fn({str, arr}) ->
        strips_in_slots({arr, String.length(str)})
      end)
  end

  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
  end


  @doc """
  if the two arrays are the same length then we can match them
  and output the

  Example:
          iex> Advent12.match_equals( {["??", "??", "?##"], [1, 1, 3]})
          {:ok, [ {"??",[1]}, {"??",[1]}]}
          iex> Advent12.match_equals({["????", "#", "#"], [4, 1, 1]})
          {:ok, [ ]}
          iex> Advent12.match_equals({["????", "##"], [4, 1, 1]})
          {:err}
  """
  def match_equals({code, points}) do
    if length(code) == length(points) do
      # zip the two arrays together
      zip = Enum.zip(code, points)
      # eliminate any exact matches
      |> Enum.reject(fn({a,b}) -> String.length(a) == b end)
      # put the count in an array to match other uses
      |> Enum.map(fn({a,b}) -> {a,[b]} end)
      { :ok, zip }
    else
      { :err }
    end
  end


  @doc """
  given an array of integers, return an array of arrays
  where each array is an ordered combination of the input array sliced into n parts
  Example:
          iex> Advent12.generate_combinations([1,2,3], 1)
          [[[1, 2, 3]]]

          iex> Advent12.generate_combinations([1,2,3], 2)
          [
            [[1], [2, 3]],
            [[1, 2], [3]]
          ]

          iex> Advent12.generate_combinations([1,2,3,4], 2)
          [
            [[1], [2, 3, 4]],
            [[1, 2], [3, 4]],
            [[1, 2, 3], [4]]
          ]

          iex> Advent12.generate_combinations([1,2,3,4], 3)
          [
            [[1], [2], [3, 4]],
            [[1], [2, 3], [4]],
            [[1, 2], [3], [4]]
          ]
          iex> Advent12.generate_combinations([1,2,3,4], 4)
          [[[1], [2], [3], [4]]]


  """
  def generate_combinations(list, n) when n > 1 do
    1..(length(list) - n + 1)
    |> Enum.flat_map(fn i ->
      {left, right} = split_at(list, i)
      Enum.map(generate_combinations(right, n - 1), &([left] ++ &1))
    end)
  end

  def generate_combinations(list, 1), do: [[list]]

  defp split_at(list, i), do: {Enum.slice(list, 0..i - 1), Enum.slice(list, i..-1)}


end
