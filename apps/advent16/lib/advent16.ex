defmodule Advent16 do
  @moduledoc """
  Documentation for `Advent16`. Day 16: The Floor Will Be Lava
  """


  @doc """
  Parsing
  read each line into a number array.
  Example:

          iex> Advent16.parse_line("rn=1,cm-,qp=3")
  """
  def parse_line(line) do
    line
    |> String.trim()
  end

  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.join("")  # Concatenate all the strings into a single string
    |> String.replace("\n", "")  # Remove all newline characters
    |> String.graphemes()
    |> Enum.with_index(0)  # Add an index starting from 1 to each element
    |> Enum.map(fn {ch, i} -> {i, ch} end)  # Convert each element to a tuple
    |> Enum.into(%{})  # Convert the result to a map
  end


  @doc """
  Move rules
  takes a direction and a position and returns the new position
  if split then returns two positions and directions.
  |
  after each rule we return an array of one or two elements each of which
  contains the next direction and position.

  if the new position leaves the map then we return [{:out, pos}]
  Example:


  """
  # @rules %{
  #   "." => fn ({dir, pos}) ->
  #     case dir do
  #       :up -> [{:up, pos - @row}]
  #       :right -> [{:right, pos + 1}]
  #       :down -> [{:down, pos + @row}]
  #       :left -> [{:left, pos - 1}]
  #     end
  #   end,
  #   "|" => fn ({dir, pos}) ->
  #     case dir do
  #       :up -> [{:up, pos - @row}]
  #       :left -> [{:up, pos - @row}, { :down, pos + @row}]
  #       :down -> [{:down, pos + @row}]
  #       :right -> [{:up, pos - @row}, { :down, pos + @row}]
  #     end
  #   end,

  #   "-" => fn ({dir, pos}) ->
  #     case dir do
  #       :up -> [{:left, pos - 1}, { :right, pos + 1}]
  #       :left -> [{ :left, pos - 1}]
  #       :down -> [{:left, pos - 1}, { :right, pos + 1}]
  #       :right ->  [{ :right, pos + 1}]
  #     end
  #   end,

  #   "/" => fn ({dir, pos}) ->
  #     case dir do
  #       :up -> [{:right, pos + 1}]
  #       :left -> [{:down, pos + @row}]
  #       :down -> [{:left, pos - 1}]
  #       :right -> [{:up, pos - @row}]
  #     end
  #   end,

  #   "\\" => fn ({dir, pos}) ->
  #     case dir do
  #       :up -> [{:left, pos - 1}]
  #       :left -> [{:up, pos - @row}]
  #       :down -> [{:right, pos + 1}]
  #       :right -> [{:down, pos + @row}]
  #     end
  #   end
  # }
  @row 110

  def rule({dir, pos}, ch) when dir == :up and ch in [".", "|"], do: [{:up, pos - @row}]
  def rule({dir, pos}, ch) when dir == :down and ch in [".", "|"], do: [{:down, pos + @row}]
  def rule({dir, pos}, ch) when dir == :left and ch in [".", "-"], do: [{:left, pos - 1}]
  def rule({dir, pos}, ch) when dir == :right and ch in [".", "-"], do: [{:right, pos + 1}]
  def rule({dir, pos}, ch) when dir in [:left, :right] and ch == "|", do: [{:up, pos - @row}, { :down, pos + @row}]
  def rule({dir, pos}, ch) when dir in [:up, :down] and ch == "-", do: [{:left, pos - 1}, { :right, pos + 1}]
  def rule({dir, pos}, ch) when dir == :up and ch == "/", do: [{:right, pos + 1}]
  def rule({dir, pos}, ch) when dir == :down and ch == "\\", do: [{:right, pos + 1}]
  def rule({dir, pos}, ch) when dir == :left and ch == "/", do: [{:down, pos + @row}]
  def rule({dir, pos}, ch) when dir == :right and ch == "\\", do: [{:down, pos + @row}]
  def rule({dir, pos}, ch) when dir == :down and ch == "/", do: [{:left, pos - 1}]
  def rule({dir, pos}, ch) when dir == :up and ch == "\\", do: [{:left, pos - 1}]
  def rule({dir, pos}, ch) when dir == :left and ch == "\\", do: [{:up, pos - @row}]
  def rule({dir, pos}, ch) when dir == :right and ch == "/", do: [{:up, pos - @row}]


  def apply_rule(move, ch) do
    # IO.puts("apply_rule #{ch}")
    off_map = fn ({dir, pos}) ->
      case dir do
        :up -> if pos < 0, do: {:out, pos}, else: {dir, pos}
        :right -> if rem(pos, @row) == 0, do: {:out, pos}, else: {dir, pos}
        :down -> if pos >= @row * @row, do: {:out, pos}, else: {dir, pos}
        :left -> if rem(pos+@row, @row) == @row - 1, do: {:out, pos}, else: {dir, pos}
      end
    end
    rule(move, ch) |> Enum.map(off_map)
  end

  @doc """
  ray trace
  starting at the initial position and direction { :right, 0 }
  we apply the rule to the character at the position to get the next position
  and direction.  We continue until we get { :out, pos}

  ray_trace(initial_acc, 0, width, initial_dir, initial_pos, map)

  Example:

  """
  def ray_trace(acc, {:out, _} = _move, _map), do: acc

  def ray_trace(acc, move, map) do
    if move in acc do
      acc
    else
      acc = [move | acc]
      {_, pos} = move
      case apply_rule(move, Map.get(map, pos)) do
        [move] -> ray_trace(acc, move, map)
        [move1, move2] ->
          if move1 in acc or move2 in acc do
            acc
          else
            ray_trace(acc, move1, map)
            |> ray_trace(move2, map)
          end
        end
    end
  end



  @doc """
  count the number of unique pos values in the map
  """
  def count_pos(map) do
    map
    |> Enum.map(fn {_dir, pos} -> pos end)
    |> Enum.uniq()
    |> Enum.count()
  end

  @doc """
  do the thing part 1

  """
  def run1(file_path, _widht) do
    file_path
    |> parse_file()
  end

  @doc """
  do the thing for part 2
  iterate over all 4 sides and all positions on each side
  """
  def run2(file_path) do
    map = parse_file(file_path)
    [:left, :right, :up, :down]
    |> Enum.flat_map(fn dir ->
      IO.inspect(dir, label: "dir")
      0..109
      |> Enum.map(fn i ->
        Advent16.ray_trace([], {dir, i}, map)
        |> Advent16.count_pos()
        |> IO.inspect(label: "count")
      end)
    end)

    |> IO.inspect(label: "end")
    |> Enum.max()
    |> IO.inspect()
  end

  def run3(file_path) do
    map = parse_file(file_path)
    tasks = for dir <- [:left, :right, :up, :down], i <- 0..109 do
      Task.async(fn ->
        Advent16.ray_trace([], {dir, i}, map)
        |> Advent16.count_pos()
      end)
    end

    tasks
    |> Enum.map(&Task.await(&1, 10000))
    |> Enum.max()
  end
end
