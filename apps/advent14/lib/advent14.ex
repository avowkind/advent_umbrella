defmodule Advent14 do
  @moduledoc """
  Documentation for `Advent14`.
  Day 14: Parabolic Reflector Dish
  """

  @doc """
  transpose an array of arrays - found on stack overflow
  Example:

          iex> Advent14.transpose([[1,2],[3,4],[5,6]])
          [[1, 3, 5], [2, 4, 6]]
  """
  def transpose([[] | _]), do: []
  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  @doc """
  Parsing
  read each line into a number array.
  . 0
  O 1
  # 2
  Example:

          iex> Advent14.parse_line(".O.#.O#...")
          [0, 1, 0, 2, 0, 1, 2, 0, 0, 0]
  """
  def parse_line(line) do
    line
    |> String.trim()
    |> String.codepoints()
    # replace . with 0 and # with 1
    |> Enum.map(fn "." -> 0; "O" -> 1; "#" -> 2 end)
  end

  @doc """
  split at the rock (2) break the list into sublists
  """
  def split_at_rock(list) do
    case Enum.split_while(list, fn {x, _} -> x != 2 end) do
      {before_2, [{2, _} | after_2]} ->
        [before_2 | split_at_rock(after_2)]
      {before_2, []} ->
        [before_2]
    end
  end

    @doc """
  split at the rock (2) break the list into sublists
  Example:

            iex> Advent14.split_at_rock2([0, 1, 0, 2, 0, 1, 2, 0, 0, 0])
            [[0, 1, 0], [0, 1], [0, 0, 0]]
  """
  def split_at_rock2(list) do
    case Enum.split_while(list, fn x -> x != 2 end) do
      {before_2, [2 | after_2]} ->
        [before_2 | split_at_rock2(after_2)]
      {before_2, []} ->
        [before_2]
    end
  end
  @doc """
  calculate the score for a sub array
  Example:

          iex> Advent14.sum_top(10, 3)
          27
          iex> Advent14.sum_top(10, 1)
          10
          iex> Advent14.sum_top(10, 0)
          0
  """
  def sum_top(_, 0) do 0 end
  def sum_top(top, 1) do top end
  def sum_top(top, count) do
    Enum.reduce(0..count-1, 0, fn i, acc ->
      acc + top - i end)
  end

  @doc """
  score the sub array
  first rework into { the first index, the number of 1s}
  Example:

          iex> Advent14.score_sub([{0, 10}, {1, 9}, {0, 8}])
          10
          iex> Advent14.score_sub([{0, 10}, {1, 9}, {1, 8}])
          19

  """
  def score_sub([]) do 0 end

  def score_sub(list) do
    {_, top} = hd(list)
    count = Enum.count(list, fn {x, _} -> x == 1 end)
    sum_top(top, count)

  end



  @doc """
  Slide each rock to the left until it hits the head or a #
  i.e move the 1 to the left if it is not at the head or a 2
  2s and 0 do not move

  i.e swap (0,1) => (1, 0)
  Example:

          iex> Advent14.slide_left([0, 1, 0, 2, 0, 0, 0, 0, 0, 0])
          10
          iex> Advent14.slide_left([0,1,0,2, 0, 1,2,0,0,1])
          19
  """
  def slide_left(list) do
    list
    |> Enum.with_index(fn x, i -> { x, length(list) -i} end)
    |> split_at_rock()
    |> Enum.map(fn x -> score_sub(x) end)
    |> Enum.sum()
  end

    @doc """
  Slide each rock to the left until it hits the head or a #
  i.e move the 1 to the left if it is not at the head or a 2
  2s and 0 do not move

  i.e swap (0,1) => (1, 0)
  Example:

          iex> Advent14.slide_left2([0, 1, 0, 2, 0, 0, 0, 0, 0, 1])
          [1, 0, 0, 2, 1, 0, 0, 0, 0, 0]
  """
  def slide_left2(list) do
    list
    |> split_at_rock2()
    |> Enum.map(&slide_ones_to_left/1)
    |> Enum.intersperse([2])
    |> List.flatten()
  end

  defp slide_ones_to_left(list) do
    count_ones = Enum.count(list, &(&1 == 1))
    count_zeros = Enum.count(list, &(&1 == 0))
    ones = List.duplicate(1, count_ones)
    zeros = List.duplicate(0, count_zeros)
    ones ++ zeros
  end
  @doc """
  Parsing
  read each line into a number array.
  first we want to read the table, convert to digits
   and transpose so that we can operate on one row at a time.

   |> Enum.reduce( 0, fn x, acc -> acc * 2 + x end)
    [acc | val]
  Example:

  """
  def parse_file(file_path) do
    IO.puts("parse_file")
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
    |> transpose()
    |> IO.inspect()

    |> Enum.map(&slide_left/1)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()

  end

  @doc """
  rotate the matrix 90 degrees
  [[1,2]  [ 5,3,1]
   [3,4], [ 6,4,2]
   [5,6]]
  Example:

          iex> Advent14.rotate90([[1,2],[3,4],[5,6]])
          [[5,3,1],[6,4,2] ]

          iex> Advent14.rotate90([[5,3,1],[6,4,2] ])
          [ [6,5], [4,3], [2,1]]

          iex> [[1,2],[3,4],[5,6]] |> Advent14.rotate90() |> Advent14.rotate90() |> Advent14.rotate90() |> Advent14.rotate90()
          [[1,2],[3,4],[5,6]]
  """
  def rotate90(matrix) do
    matrix
    |> Enum.reverse()
    |> List.zip() # Transpose the matrix
    |> Enum.map(&Tuple.to_list/1) # Convert each row to a list
  end
  def rotate90_left(matrix) do
    matrix
    |> Enum.map(&Enum.reverse/1) # Reverse each row
    |> List.zip() # Transpose the matrix
    |> Enum.map(&Tuple.to_list/1) # Convert each row to a list
  end
  # iex> Advent14.parse_file("data/test.txt")
  # 136

  # iex> Advent14.parse_file("data/data.txt")
  # 108813

  @doc """
  repeat the rotation and slide 4 times
  """
  def cycle({list, hashes} ) do
    res = 1..4
    |> Enum.reduce(list, fn _, acc ->
      acc
      |> Enum.map(&slide_left2/1)
      |> rotate90()
    end)
    {res, hashes ++ [hash(res)]}
  end

  def spins(grid, count) do
    IO.puts("spins #{count}")
    spin = 1..count
    |> Enum.reduce({grid, []}, fn _, acc ->
      res = acc |> cycle()
      {g1, hash} = res
      score = g1 |> Enum.map(&score2/1)
        |> IO.inspect()
        |> Enum.sum()
        IO.puts("score #{score}")
        IO.inspect(hash)
      res
    end)
    { g1, _ } = spin

    spin
  end

  @doc """
  hash the grid

  Example:
          iex> Advent14.hash([[1,2],[3,4],[5,6]])
          3895835992
  """

  @offset_basis 2166136261
  @prime 16777619

  def hash(list) do
    list
    |> List.flatten()
    |> Enum.reduce(@offset_basis, &hash_byte/2)
  end

  defp hash_byte(byte, hash) do
    (hash * @prime) |> rem(2**32) |> Bitwise.bxor(byte)
  end

  # #   def hash_sha(grid) do
  #   str = grid
  #   |> List.flatten()
  #   |> Enum.join(",")
  #   :crypto.hash(:sha256, str)
  # end

  def find_cycle(stream) do
    Enum.reduce_while(stream, {0, %{}}, fn number, {position, map} ->
      if Map.has_key?(map, number) do
        {:halt, {map[number], position - map[number]}}
      else
        {:cont, {position + 1, Map.put(map, number, position)}}
      end
    end)
  end

  def score2(list) do
    list
    |> Enum.with_index(fn x, i -> { x, length(list) -i} end)
    # |> IO.inspect(label: "score2")
    |> Enum.map(fn {x, val} ->  val * if x == 1, do: 1, else: 0 end)
    |> Enum.sum()
  end

  @doc """
  for part 2 we need to shake the board around for
  1000000000 times and then do the scoring.
  so we need to actually move the stuff over and over again

  Example:
          iex> Advent14.run2("data/data.txt")

  """
  def run2(file_path) do
    grid = file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
    |> rotate90_left()

    { _grid, hashes} = grid |> spins(100)
    { start, count } = find_cycle(hashes)
    IO.puts "start #{start} count #{count}"
    length = 1_000_000_000
    { g1, _} = grid |> spins(start)
    IO.inspect(g1, label: "g1")

    # here we work out how many cycles fit in the length
    # and then we do the remainder
    { g2, _} = g1 |> spins(count)
    IO.inspect(g2, label: "g2")
    left = rem(length - start, count)
    IO.puts("left #{left}")
    { g3, _} = g2 |> spins(left)

    g3 |> IO.inspect(label: "g3")
    |> Enum.map(&score2/1)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()

  end
  # 1_000_000_000
  # would take 1000 * 25.3 secs = 25300 secs = 7 hours

end
