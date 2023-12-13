defmodule Advent13 do
  @moduledoc """
  Documentation for `Advent13`.
  """


  @doc """
  Parsing
  read each line into a number array.
  then convert to binary number

  Example:

          iex> Advent13.parse_line("...#......")
          [0, 0, 0, 1, 0, 0, 0, 0, 0, 0]
          iex> Advent13.parse_line("...#.....#")
          [0, 0, 0, 1, 0, 0, 0, 0, 0, 1]
  """
  def parse_line(line) do
    line
    |> String.trim()
    |> String.codepoints()
    # replace . with 0 and # with 1
    |> Enum.map(fn "." -> 0; "#" -> 1 end)
  end

  def split_at_empty(list) do
    case Enum.split_while(list, &(&1 != [])) do
      {before_empty, [_ | after_empty]} ->
        [before_empty | split_at_empty(after_empty)]
      {before_empty, []} ->
        [before_empty]
    end
  end

  @doc """
  convert the digit arrays to number arrays
  Example:
        iex> Advent13.to_numbers([[0, 0, 0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 1]])
        [64, 65]
  """
  def to_numbers(list) do
    list
    |> Enum.map(
        fn x ->
          Enum.reduce(x, 0, fn x, acc -> acc * 2 + x end) end)
  end

  def all_same?(list) do
    list
      |> Enum.all?(fn {x, y} -> x == y end)
  end

  @doc """
  check if two numbers differ by a single bit
  Example:

          iex> Advent13.single_bit_difference?(1, 3)
          true
          iex> Advent13.single_bit_difference?(4, 1)
          false
  """
  def single_bit_difference?(a, b) do
    Bitwise.band((Bitwise.bxor(a,b)),(Bitwise.bxor(a,b) - 1)) == 0
  end

  @doc """
  check if all but one of the pairs are the same
  the one difference must be a single bit
  """

  def all_bar_one?(list) do
    {same, diff} = Enum.split_with(list, fn {x, y} -> x == y end)

    case diff do
      [{a, b}] when Bitwise.band((Bitwise.bxor(a,b)),(Bitwise.bxor(a,b) - 1)) == 0 -> Enum.all?(same, fn {x, y} -> x == y end)
      _ -> false
    end
  end

  @doc """
    are mirrors when the two arrays are the same
    when the first is reversed

    Example:

          iex> Advent13.mirrored_at?(3, [358, 90, 385, 385, 90, 102, 346])
          0
          iex> Advent13.mirrored_at?(3, [102, 90, 385, 385, 90, 102, 346])
          3
  """
  def mirrored_at?(count, list) do
    {list1, list2} = Enum.split(list, count)

    Enum.zip(Enum.reverse(list1), list2)
    # |> all_same?()
    |> all_bar_one?()
    |> case do
      true -> count
      false -> 0
    end
  end

  @doc """
  find rows where two adjacent numbers are the same
  or only differ by one bit
  """
  def find_candidate_lines(list) do
    list
    |> Enum.slice(0..-2)
    |> Enum.reduce([], fn {a, i}, acc ->
      { b, _ }  = Enum.at(list, i + 1)
      if a == b or single_bit_difference?(a,b) do
        [i+1 | acc]
      else
        acc
      end
    end)
  end

  @doc """
    find the best mirror. given mulitple mirror candidates
    we want to know which gives the longer mirror.
    This will be the one closest to the centre.

  """
  def find_best_mirror(list, centre_index) do
    list |> Enum.reduce(0, fn x, acc ->
      if abs(x - centre_index) < abs(acc - centre_index) do
        x
      else
        acc
      end
    end)
  end

  @doc """
    scan the list of numbers and two adjacent numbers are the same
    return the split point
    Example:


          iex> Advent13.find_mirror([281, 281, 126, 185, 286, 156, 265,336, 485, 485, 336, 265, 156, 286, 185, 124, 281])
          9

  """
  def find_mirror(list) do
    centre_index = div(Enum.count(list), 2)+1
    list
    |> Enum.with_index()
    |> find_candidate_lines()
    |> Enum.map(&mirrored_at?(&1, list))
    |> find_best_mirror(centre_index)
  end

  @doc """
  transpose an array of arrays - found on stack overflow
  Example:

          iex> Advent13.transpose([[1,2],[3,4],[5,6]])
          [[1, 3, 5], [2, 4, 6]]
  """
  def transpose([[] | _]), do: []
  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end


  def to_transposed_pairs(list) do
    rows = list |> to_numbers()
    cols = list |> transpose() |> to_numbers()
    { rows, cols}
  end

  @doc """
  finds the mirror points in the rows and columns

  """
  def check_grid({rows,cols}) do
    mrows = rows |> find_mirror()
    mcols = cols |> find_mirror()
    { mrows, mcols}
    # |> IO.inspect()
  end


  @doc """
  score the grid
  Example:


  """
  def score(grid) do
    grid
    |> Enum.map(fn {x, y} -> x * 100 + y end)
  end


  @doc """
  Parsing
  read each line into a number array.
   |> Enum.reduce( 0, fn x, acc -> acc * 2 + x end)
    [acc | val]
  Example:

          iex> Advent13.parse_file("data/data.txt")

  """
  def parse_file(file_path) do
    IO.puts("parse_file")
    IO.inspect(file_path)
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
    |> split_at_empty()
    |> Enum.map(&to_transposed_pairs/1)
    |> Enum.map(&check_grid/1)
    |> score()
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()

  end



end
