defmodule Advent14 do
  @moduledoc """
  Documentation for `Advent14`.
  Day 14: Parabolic Reflector Dish
  """

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

  This version does not actually move the rocks.
  We split the array into sub arrays marked by 2s,
  The count  how many 1s there are in each sub array
  and then calculate the score for each sub array

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
  This version required for part2 does move the rocks as we need
  their new positions.
  Slide each rock to the left until it hits the head or a #
  i.e move the 1 to the left if it is not at the head or a 2
  2s and 0 do not move

  Updated version - do all in one pass - here we accumulate any zeros in a counter
  and pass through any ones, and when we hit a 2 we add the zeros to the list
  and reset the counters, check what happens if there are zeros left at the end
  Example:

          iex> Advent14.slide_left2([0, 1, 0, 2, 0, 0, 0, 0, 0, 1])
          [1, 0, 0, 2, 1, 0, 0, 0, 0, 0]

          iex> Advent14.slide_left2([0, 1, 0, 2, 1, 1, 2, 0, 0, 1])
          [1, 0, 0, 2, 1, 1, 2, 1, 0, 0]

          iex> Advent14.slide_left2([0, 1, 0, 0, 1, 1, 0, 0, 1, 0])
          [1, 1, 1, 1, 0, 0, 0, 0, 0, 0]
  """
  def slide_left2(list) do
    Enum.reduce(list, {[], 0, 0}, fn
      1, {acc, ones, zeros} -> {acc, ones + 1, zeros} # accum 1s
      0, {acc, ones, zeros} -> {acc, ones, zeros + 1} # accum 2s
      2, {acc, ones, zeros} -> {acc ++  List.duplicate(1, ones) ++ List.duplicate(0, zeros) ++ [2], 0, 0}
    end)
    # add any left over 1s and 0s and return acc
    |> then(fn {acc, ones, zeros} -> acc ++ List.duplicate(1, ones) ++ List.duplicate(0, zeros) end)
  end

  # original version - split into sub groups and count 1s
  # def slide_left2(list) do
  #   list
  #   |> split_at_rock2()
  #   |> Enum.map(&slide_ones_to_left/1)
  #   |> Enum.intersperse([2])
  #   |> List.flatten()
  # end

  # defp slide_ones_to_left(list) do
  #   count_ones = Enum.count(list, &(&1 == 1))
  #   count_zeros = Enum.count(list, &(&1 == 0))
  #   ones = List.duplicate(1, count_ones)
  #   zeros = List.duplicate(0, count_zeros)
  #   ones ++ zeros
  # end


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
    |> Enum.zip()
    |> Enum.map(&slide_left/1)
    |> Enum.sum()

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

  @doc """
  perform count cycles of the grid, each returns the grid to the North
  facing position.
  grid is a tuple of the grid and the hash accumulator
  """
  def spins(grid, count) do
    1..count |> Enum.reduce({grid, []}, fn _, acc -> acc |> cycle() end)
  end

  @doc """
  hash the grid
  we want to compress the grid into a single number that we can use
  to compare with other grids and thus detect cycles.
  We use the FNV-1a hash algorithm to get a single value.
  it does not need to be secure and is fast.

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

  # this built in could work just as well but the output is a long string
  # #   def hash_sha(grid) do
  #   str = grid
  #   |> List.flatten()
  #   |> Enum.join(",")
  #   :crypto.hash(:sha256, str)
  # end

  @doc """
  find the cycle in the stream of hashes
  we just need to find the first repeat occurance of the hash,
  The cycle length is the different in positions between the first and second
  occurance. The start position is the position of the first occurance.
  works so long as the hash function does not generate duplicates for different maps.
  """
  @spec find_cycle(Stream.t()) :: {integer, integer}
  def find_cycle(stream) do
    Enum.reduce_while(stream, {0, %{}}, fn number, {position, map} ->
      if Map.has_key?(map, number) do
        {:halt, {map[number], position - map[number]}}
      else
        {:cont, {position + 1, Map.put(map, number, position)}}
      end
    end)
  end

  @doc """
  We score the board by multiplying the value of each cell
  by its diminishing distance from the start. with the first multiplier
  being the length of the list.
  Example:

          iex> Advent14.score([0, 1, 0, 2, 0, 1, 2, 0, 0, 0])
          14
          iex> Advent14.score([0, 1, 0, 2, 0, 1, 2, 0, 0, 1])
          15
  """
  def score(list) do
    list
    |> Enum.with_index(fn x, i -> { x, length(list) -i} end)
    |> Enum.map(fn {x, val} ->  val * if x == 1, do: 1, else: 0 end)
    |> Enum.sum()
  end

  @doc """
  For part 2 we need to shake the board around for
  1_000_000_000 times and then do the scoring.
  so we need to actually move the stuff over and over again
  and then score it.

  This would take too long so we assume that after n rotations we will
  return to one of our previous positions and then we can work out
  the cycle length.
  We then work out how many cycles fit into 1_000_000_000 - first repeat
  and then do the remainder.

  1_000_000_000 would take 1000 * 25.3 secs = 25300 secs = 7 hours

  @initial_tries is the number of rotations we attempt before searching
  for the first cycle this is a trade off between spinning for a while
  or having to check the list after every spin.
  Example:

          iex> Advent14.run2("data/test.txt")
          64

          iex> Advent14.run2("data/data.txt")
          104533
  """
  @length 1_000_000_000
  @initial_tries 100
  def run2(file_path) do
    grid = file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
    |> rotate90_left()

    { start, count } = grid
      |> spins(@initial_tries)
      |> then(fn {_, hashes} -> find_cycle(hashes) end)

    left = rem(@length - start, count)
    IO.puts "start #{start} count #{count}, left #{left}"
    grid
    |> spins(start) |> then(fn {g, _} -> g end)
    |> spins(count) |> then(fn {g, _} -> g end)
    |> spins(left)  |> then(fn {g, _} -> g end)
    |> Enum.map(&score/1)
    |> Enum.sum()
    |> IO.inspect()

  end


end
