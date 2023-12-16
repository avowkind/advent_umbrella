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

          iex> Advent16.apply_rule({:up, 15}, "|", 10)
          [{:up, 5}]
          iex> Advent16.apply_rule({:left, 15}, "|", 10)
          [{:up, 5}, {:down, 25}]

  """
  def apply_rule(move, ch, row) do
    # IO.puts("apply_rule #{ch}")
    rules = %{
      "." => fn ({dir, pos}) ->
        case dir do
          :up -> [{:up, pos - row}]
          :right -> [{:right, pos + 1}]
          :down -> [{:down, pos + row}]
          :left -> [{:left, pos - 1}]
        end
      end,
      "|" => fn ({dir, pos}) ->
        case dir do
          :up -> [{:up, pos - row}]
          :left -> [{:up, pos - row}, { :down, pos + row}]
          :down -> [{:down, pos + row}]
          :right -> [{:up, pos - row}, { :down, pos + row}]
        end
      end,

      "-" => fn ({dir, pos}) ->
        case dir do
          :up -> [{:left, pos - 1}, { :right, pos + 1}]
          :left -> [{ :left, pos - 1}]
          :down -> [{:left, pos - 1}, { :right, pos + 1}]
          :right ->  [{ :right, pos + 1}]
        end
      end,

      "/" => fn ({dir, pos}) ->
        case dir do
          :up -> [{:right, pos + 1}]
          :left -> [{:down, pos + row}]
          :down -> [{:left, pos - 1}]
          :right -> [{:up, pos - row}]
        end
      end,

      "\\" => fn ({dir, pos}) ->
        case dir do
          :up -> [{:left, pos - 1}]
          :left -> [{:up, pos - row}]
          :down -> [{:right, pos + 1}]
          :right -> [{:down, pos + row}]
        end
      end
    }
    off_map = fn ({dir, pos}) ->
      case dir do
        :up -> if pos < 0, do: {:out, pos}, else: {dir, pos}
        :right -> if rem(pos, row) == 0, do: {:out, pos}, else: {dir, pos}
        :down -> if pos >= row * row, do: {:out, pos}, else: {dir, pos}
        :left -> if rem(pos+row, row) == row - 1, do: {:out, pos}, else: {dir, pos}
      end
    end

    Map.get(rules, ch).(move) |> Enum.map(off_map)
  end

  @doc """
  ray trace
  starting at the initial position and direction { :right, 0 }
  we apply the rule to the character at the position to get the next position
  and direction.  We continue until we get { :out, pos}

  ray_trace(initial_acc, 0, width, initial_dir, initial_pos, map)

  Example:

          iex> Advent16.ray_trace([], 0, {:right, 0}, 2,  %{ 0 => ".",1 => ".",2 => ".",3 => ".",})
  """
  def ray_trace(acc, i, {dir, pos}, width, map) do
    # IO.puts("ray_trace #{i} #{dir} #{pos}")
    # if this position is already in the accumulator then we are done
    if Enum.member?(acc, {dir, pos}) do
      IO.puts("already in acc")
      acc
    else
    if i > 600 do
      # IO.puts("too many iterations")
      acc
    else
      case dir do
        :out ->
          acc
        _ ->
          new_acc = apply_rule({dir, pos}, Map.get(map, pos), width)
            |> Enum.reverse()
            |> Enum.flat_map(fn {dir, pos} -> ray_trace(acc, i + 1, {dir, pos}, width, map) end)
          [{dir,pos} | new_acc]
      end
    end
  end
    # |> IO.inspect(label: "end ray_trace #{i}")
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
  do the thing
  Example:

  """
  def run1(file_path, _widht) do
    file_path
    |> parse_file()
    |> IO.inspect(label: "map")
  end
  # iex> Advent16.run1("data/straightrun.txt", 10)


  def print_grid(map, width) do
    # Initialize the grid
    grid = List.duplicate(List.duplicate(".", width), width)

    # Update the grid based on the map
    updated_grid = Enum.reduce(map, grid, fn {dir, val}, acc ->
      row = div(val, width)
      col = rem(val, width)

      case dir do
        :right -> List.replace_at(List.replace_at(acc, row, List.replace_at(Enum.at(acc, row), col, "#")), row, Enum.at(acc, row))
        :down -> List.replace_at(List.replace_at(acc, row, List.replace_at(Enum.at(acc, row), col, "#")), row, Enum.at(acc, row))
        :left -> List.replace_at(List.replace_at(acc, row, List.replace_at(Enum.at(acc, row), col, "#")), row, Enum.at(acc, row))
        :up -> List.replace_at(List.replace_at(acc, row, List.replace_at(Enum.at(acc, row), col, "#")), row, Enum.at(acc, row))
      end
    end)

    # Print the grid
    Enum.each(updated_grid, fn row ->
      IO.puts(Enum.join(row, ""))
    end)
  end

end
