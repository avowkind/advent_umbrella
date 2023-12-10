defmodule Advent10 do
  @moduledoc """
  Documentation for `Advent10`.
  """

  @doc """
  read all the lines in the file into a list of number arrays.

  Example:

          iex> Advent10.parse_file("data/test1.txt")
          [
              ".....",
              ".S-7.",
              ".|.|.",
              ".L-J.",
              "....."
            ]
  """

  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&String.trim/1)
  end

  def simple_grid() do
    parse_file("data/test1.txt")
  end
  @doc """
  find character at x,y pos in the grid
  Example:

        iex> Advent10.char_at({1, 1}, ["abc", "def", "ghi"] )
        "e"

        iex> Advent10.char_at({2, 2}, ["abc", "def", "ghi"] )
        "i"
  """
  def char_at({x, y}, grid) do
    grid
    |> Enum.at(y)
    |> String.at(x)
  end

  @doc """
  horrible function to write a character at a given position in the grid
  given that grids are immutable. we modify the line and return a new grid.

  Example:

        iex> Advent10.write_char_at({1, 1}, ["abc", "def", "ghi"], "X" )
        ["abc", "dXf", "ghi"]

        iex> Advent10.write_char_at({2, 2}, ["abc", "def", "ghi"], "X" )
        ["abc", "def", "ghX"]
  """
  def write_char_at({x, y}, grid, char) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {line, i} ->
      if i == y do
          before = String.slice(line, 0, x)
          rest = String.slice(line, x + 1, String.length(line))
          before <> char <> rest
      else
        line
      end
    end)
  end


  @doc """
  get the dimensions of the grid
  Example:

        iex> Advent10.dimensions(["abc", "def", "ghi"])
        {3, 3}

        iex> Advent10.simple_grid() |> Advent10.dimensions()
  """
  def dimensions(grid) do
    {String.length(Enum.at(grid, 0)), Enum.count(grid)}
  end

  @doc """
  Find the offset of an S in a string
  Example:

        iex> Advent10.find_s_in_line("aq8Shfq43hfreuifh84iuqreuf")
        3
        iex> Advent10.find_s_in_line("aq8xhfq43hfreuifh84iuqreuf")
        nil

  """
  def find_s_in_line(line) do
    case Regex.run(~r/S/, line, return: :index) do
      nil -> nil
      [{x, _}] -> x
    end
  end

  @doc """
  find the x, y pos of the start in the grid
  Example:

        iex> Advent10.find_start(["abc..", "dx77f", "gSiJJ"])
        {1, 2}

        <!-- iex> Advent10.find_start(@simple_grid)
        {1, 1} -->
  """
  def find_start(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {line, y} -> {find_s_in_line(line), y} end)
    |> Enum.find(fn {x, _} -> x != nil end)
  end



  @doc """
  given a position {x,y} and a Direction { :N, :E, :S, :W } return the next position
  Example:

          iex> Advent10.move_direction({1, 1}, :E)
          {2, 1}
          iex> Advent10.move_direction({1, 1}, :S)
          {1, 2}
          iex> Advent10.move_direction({1, 1}, :W)
          {0, 1}
          iex> Advent10.move_direction({1, 1}, :N)
          {1, 0}

    TODO:  do we need to check for off the map.
  """
  def move_direction({x, y}, _) when x < 0 or y < 0 do
    nil
  end

  def move_direction({x, y}, dir) do
    case dir do
      :N -> {x, y - 1}
      :E -> {x + 1, y}
      :S -> {x, y + 1}
      :W -> {x - 1, y}
    end
  end

  @valid_moves %{
    N: ["|", "F", "7"],
    E: ["-", "J", "7"],
    S: ["|", "J", "L"],
    W: ["-", "F", "L"]
  }

  @doc """
    given a direction and a character return the next direction
    Example:

            iex> Advent10.moves(:N, "|")
            :N
            iex> Advent10.moves(:N, "F")
            :E
            iex> Advent10.moves(:N, "7")
            :W
            iex> Advent10.moves(:E, "-")
            :E
            iex> Advent10.moves(:E, "J")
            :N
            iex> Advent10.moves(:E, "7")

  """
  def moves(dir, char) do

    legal_moves = %{
      :N => %{
        "|" => :N,
        "F" => :E,
        "7" => :W
      },
      :E => %{
        "-" => :E,
        "J" => :N,
        "7" => :S
      },
      :S => %{
        "|" => :S,
        "J" => :W,
        "L" => :E
      },
      :W => %{
        "-" => :W,
        "F" => :S,
        "L" => :N
      }
    }
    legal_moves[dir][char]
  end


  @doc """
  given a position {x,y} and a Direction { :N, :E, :S, :W }
  and a grid return true if the move is valid
  Example:

          iex> Advent10.is_valid_move?({1, 1}, :E, Advent10.simple_grid())
          true
          iex> Advent10.is_valid_move?({1, 1}, :N, Advent10.simple_grid())
          false
  """
  def is_valid_move?({x, y}, dir, grid) do
    Enum.member?(@valid_moves[dir], char_at(move_direction({x, y}, dir), grid))
  end

  @doc """

  given a start position {x,y} and the grid find the direction of the next two positions
  Example:

          iex> Advent10.start_moves( Advent10.simple_grid())
          { {1,1,}, [:E, :S] }
  """
  def start_moves(grid) do
    start = find_start(grid)
    moves = [ :N, :E, :S, :W ] |> Enum.filter(fn dir -> is_valid_move?(start, dir, grid) end)
    { start, moves}
  end

  @doc """
  having arrived at a cell we have the position and the previous move.
  using this calculate the next valid move and thus return the new cell and previous direct.
  Example:

          iex> Advent10.next_step({:E, {3,1}}, Advent10.simple_grid())
          { :S, {3,2} }
          iex> Advent10.next_step({:S, {3,2}}, Advent10.simple_grid())
          { :S, {3,3} }
          iex> Advent10.next_step({:S, {3,3}}, Advent10.simple_grid())
          { :W, {2,3} }
  """
  def next_step({move, pos}, grid) do
    char = char_at(pos, grid)
    new_dir = moves(move, char)
    { new_dir, move_direction(pos, new_dir) }
  end

  @doc """
  follow the track recursively until we get to the given position

  """
  def follow( step, grid, counter) do
    { _, pos } = step
    if char_at(pos, grid) == "S" do
      counter
    else
      new = next_step(step, grid)
      follow( new, grid, counter + 1)
    end
  end

  @doc """
  read the file into the grid and find the start position
  then find the valid start moves.

  for each start move - follow the path until the character is S.

  Example:

            iex> Advent10.run1("data/test1.txt")
            4
  """
  def run1(file_path) do
    grid = parse_file(file_path)
    { start, [ move | _ ] }  = start_moves(grid)
    first_step = { move, move_direction(start, move)}
    follow(first_step, grid, 1) / 2
  end

  @doc """
    recursively follow the path updating accumulator grid as we go.
  """
  def follow2( step, grid, acc) do
    { _, pos } = step
    ch = char_at(pos, grid)
    if ch == "S" do
      IO.puts("found S")
      write_char_at(pos, acc, "1")
    else
      acc = case ch do
        # mark edges with 1, corners with their successor
        "|" -> write_char_at(pos, acc, "1")
        "-" -> write_char_at(pos, acc, "1")
        "F" -> write_char_at(pos, acc, "G")
        "J" -> write_char_at(pos, acc, "K")
        "L" -> write_char_at(pos, acc, "M")
        "7" -> write_char_at(pos, acc, "8")
        _ -> write_char_at(pos, acc, "X") # unexpected
      end
      # IO.inspect(acc)
      new = next_step(step, grid)
      follow2( new, grid, acc)
    end
  end

  @doc """
  process a line.

  start with counter at 0
  if we hit a line with a 1 then we increment the counter
  if we hit a corner then we increment the counter but dont again until the next corner
  third tuple element is true if we are traversing a line
  log the corner and decide if it is a line cross if the opposite direction is found
  """
  def inout_line(line) do
    line |> String.codepoints()
    |> Enum.reduce({[], 0, :no} ,
        fn ch, {l, d, crossing} ->
          case ch do
            # handle the corners
            "G" -> # top left
              {l ++ [1], d , :top}
            "8" -> # top right
              case crossing do
                :top -> {l ++ [4], d , :no} # no cross
                :bottom -> {l ++ [4], d+1, :no} # line cross
              end
            "M" -> # bottom left
              {l ++ [1], d, :bottom}
            "K" -> # bottom right
              case crossing do
                :bottom -> {l ++ [4], d, :no} # no cross
                :top -> {l ++ [4], d+1,  :no} # line cross
              end
            # handle the edges
            "1" ->
              if crossing == :no do
                {l ++ [1], d + 1,crossing} # crossing line, inc counter
              else
                {l ++ [1], d, crossing} # following line, stay same
              end
            _ ->
              case rem(d, 2) do # odd, even test
                0 -> {l ++ [0], 0, crossing} # 0 marks outside
                1 -> {l ++ [2], d, crossing} # 2 marks inside
              end
          end
        end)
    |> elem(0)
  end



  def count_twos(list) do
    list |> Enum.reduce(0, fn x, acc -> if x == 2 do acc + 1 else acc end end)
  end

  def run2(file_path) do
    grid = parse_file(file_path)
    { start, [ move | _ ] }  = start_moves(grid)
    first_step = { move, move_direction(start, move)}
    # scan the grid counting crossing points
    follow2(first_step, grid, grid) |> Enum.map(&inout_line/1)
  |> Enum.map(&count_twos/1)
  |> IO.inspect()
  |> Enum.sum()
  end
end
