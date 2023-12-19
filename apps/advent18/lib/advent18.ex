defmodule Advent18 do
  @moduledoc """
  Documentation for `Advent18`.

  stream the lines into a list of steps
  fill a graph with the steps and their corresponding coordinates and colours
  raster scan each line to find the interior count

  also print the size of the grid
  """


  @doc """
  Parsing
  read each line into a number array.
  Example:

  it can move at most three blocks in a single direction before
  it must turn 90 degrees left or right

          iex> Advent18.parse_line("R 6 (#70c710)")
          { "R", 6, "#70c710"}
  """
  def parse_line(line) do
    Regex.scan(~r/(\w) (\d+) \((#[a-fA-F0-9]{6})\)/, line)
    |> List.first()
    |> case do
      [_, dir, steps, colour] -> {dir, String.to_integer(steps), colour}
      _ -> :error
    end
  end

  @doc """
  Parsing
  read each line into a coordinate map
  Example:

          iex> Advent18.parse_file("data/test.txt")
          [
            {"R", 6, "#70c710"},
            {"D", 5, "#0dc571"},
            {"L", 2, "#5713f0"},
            {"D", 2, "#d2c081"},
            {"R", 2, "#59c680"},
            {"D", 2, "#411b91"},
            {"L", 5, "#8ceee2"},
            {"U", 2, "#caa173"},
            {"L", 1, "#1b58a2"},
            {"U", 2, "#caa171"},
            {"R", 2, "#7807d2"},
            {"U", 3, "#a77fa3"},
            {"L", 2, "#015232"},
            {"U", 2, "#7a21e3"}
          ]

  """
  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(fn line -> parse_line(line) end)
  end


  @doc """
  Build Graph

  Given the list of moves build a graph for the visited coordinates
  in this version we  allow moves up, down, left and right but not off the map

  ## Example
          iex> Advent18.parse_file("data/test.txt") |> Advent18.build_graph({0,0})
  """
  # def build_graph(plan, start) do
  #   graph = %{ start => "#000000"}
  #   plan
  #   |> Enum.reduce( {start, graph},
  #     fn {dir, steps, colour}, {{row,col}, graph} ->
  #       # IO.inspect({dir, steps, colour, pos, graph}, label: "build_graph [\n")
  #         # IO.inspect({{row,col},colour}, label: "step")
  #         next = case dir do
  #           "R" -> {row, col+steps}
  #           "L" -> {row, col-steps}
  #           "U" -> {row-steps, col}
  #           "D" -> {row+steps, col}
  #         end
  #         new_graph = Map.put(graph, next, colour)
  #         { next, new_graph }
  #       end)
  #     |> then(fn {_, graph} -> graph end)
  #     |> IO.inspect()
  # end

  def build_graph(plan, start) do
    graph = %{ }
    plan
    |> Enum.reduce( {start, graph},
      fn {dir, steps, colour}, {pos, graph} ->
        # IO.inspect({dir, steps, colour, pos, graph}, label: "build_graph [\n")
        Enum.reduce(1..steps, {pos,graph}, fn _, {{row,col}, graph} ->
          # IO.inspect({{row,col},colour}, label: "step")
          next = case dir do
            "R" -> {row, col+1}
            "L" -> {row, col-1}
            "U" -> {row-1, col}
            "D" -> {row+1, col}
          end
          # IO.inspect(next, label: "next")

          new_graph = Map.put(graph, next, colour)
          { next, new_graph }
        end)
        # |> IO.inspect(label: "\n] build_graph")

      end)
      |> then(fn {_, graph} -> graph end)
      |> IO.inspect()
  end
  @doc """
  Draw graph

  Given the graph of visited coordinates draw the grid using . for empty cells and # for visited
  """
  def draw_graph(graph) do

    IO.puts("draw_graph")
    min_row = graph |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.min()
    max_row = graph |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.max()
    min_col = graph |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.min()
    max_col = graph |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.max()
    IO.puts("min_row: #{min_row}, max_row: #{max_row}, min_col: #{min_col}, max_col: #{max_col}")
    for row <- min_row..max_row do
      IO.write("#{row} ")
      for col <- min_col..max_col do
        if Map.has_key?(graph, {row,col}) do
          IO.write("#")
        else
          IO.write(".")
        end
      end
      IO.puts("")
    end
  end

  # @doc """
  # Flood fill algorithm  - TOO SLOW
  # """
  # def count_interior_cells(graph) do
  #   {start_row, start_col} = find_start(graph)
  #   do_count_interior_cells(graph, [{start_row, start_col}], MapSet.new(), 0)
  # end

  # defp do_count_interior_cells(_graph, [], _visited, counter), do: counter

  # defp do_count_interior_cells(graph, [{row, col} | rest], visited, counter) do
  #   if within_boundaries(graph, row, col) && !Map.has_key?(graph, {row, col}) && !MapSet.member?(visited, {row, col}) do
  #     visited = MapSet.put(visited, {row, col})
  #     stack = [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}] ++ rest
  #     do_count_interior_cells(graph, stack, visited, counter + 1)
  #   else
  #     do_count_interior_cells(graph, rest, visited, counter)
  #   end
  # end
  # defp xfind_start(graph) do
  #   min_row = graph |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.min()
  #   min_col = graph |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.min()
  #   {min_row+1, min_col + 1}
  #   |> IO.inspect(label: "start")
  # end
  # defp find_start(graph) do
  #   { -166, 119}
  # end

  # defp within_boundaries(graph, row, col) do
  #   min_row = graph |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.min()
  #   max_row = graph |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.max()
  #   min_col = graph |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.min()
  #   max_col = graph |> Map.keys() |> Enum.map(fn {_, col} -> col end) |> Enum.max()

  #   row >= min_row && row <= max_row && col >= min_col && col <= max_col
  # end



  @doc """
  process a line.

  start with counter at 0
  if we hit a line with a 1 then we increment the counter
  if we hit a corner then we increment the counter but dont again until the next corner
  third tuple element is true if we are traversing a line
  log the corner and decide if it is a line cross if the opposite direction is found

  points are always corners
  in out state
  .
  ##  top
  #

  #
  ##  bottom
  .

  #
  #.  wall
  #

  if we are in top state
   .
  ##  :out
   #

   #
  ##  :in
   .


  in bottom state
   .
  ##  :in
   #

   #
  ##  :out
   .

  in in state

  # :out  substract previous start.

  """

  def scan_line(walls, graph, row) do
    walls |>
              # { ac_count, last, state, prev_state }
    Enum.reduce({0, 0, :out, :out} ,
        fn col, {count, l, state, prev_state} ->
          # check if there is a line both above and below
          above = Map.has_key?(graph, {row-1, col})
          below = Map.has_key?(graph, {row+1, col})
          right = Map.has_key?(graph, {row, col+1})
          # IO.inspect({ state, prev_state, above, below, right }, label: "above below right")
          # for the first pos we set state to start
          case state do
            :out ->
              case { above, below, right } do
                { true, true, false } -> {count+1, col, :in, :out}  # wall
                { true, false, true } -> {count+1, col, :bottom, :out} # bottom
                { false, true, true } -> {count+1, col, :top, :out} # top
                _ -> { l, :error } |> IO.inspect({ above, below, right }, label: "error")
              end
            :in ->
              # if we are in then a wall must take us out, but it could be a corner
              case { above, below, right } do
                { true, true, false } -> {count + (col - l), 0, :out, :out}  # wall
                { true, false, true } -> {count + (col - l), col, :bottom, :in} # bottom
                { false, true, true } -> {count + (col - l), col, :top, :in} # top
                _ -> { l, :error } |> IO.inspect({ above, below, right }, label: "error")
              end
            :top ->
              # if we are in top then we continue or leave in or out
              case { above, below, right } do
                { true, false, false } -> # crossing
                  case prev_state do
                    :out -> {count+1, col, :in, :out}
                    :in  -> {count+1, col, :out, :out}
                  end
                { false, true, false } -> {count+1, 0, :out, :out} # no crossing
                { _, _, true } -> {count+1, col, :top, prev_state} # continue

                _ -> { l, :error } |> IO.inspect({ above, below, right }, label: "error")
              end
            :bottom ->
              # if we are in bottom then we leave in or out
              case { above, below, right } do
                { false, true, false } ->
                  case prev_state do
                    :out -> {count+1, col, :in, :out}
                    :in  -> {count+1, col, :out, :out}
                  end
                { true, false, false } -> {count+1, 0, :out, :out} # no crossing
                { _, _, true } -> {count+1, col, :bottom, prev_state} # continue
                _ -> { l, :error } |> IO.inspect({ above, below, right }, label: "error")
              end
            _ -> { :error, "unknown state" } |> IO.inspect({ above, below, right }, label: "unknown state")
          end
        # |> IO.inspect(label: "state_changes")
        end)
        |> then(fn {count, _, _, _} -> count end)
        |> IO.inspect(label: "row #{row} count")
  end

  @doc """
  Raster scan lines to find the interior cells
  for each row, find the points of the walls in that row
  e.g ...#...#..#.#   -> 3, 7, 10, 12
  Then count the interior cells between the walls, including the walls
  e.g ...#...#..#.#   -> 3, 7, 10, 12 -> 5 + 3 = 8

  However, if we hit a wall on the scan line - e.g. ...###... then we need to determine
  if the wall is a top or bottom of the interior.  We can do this by looking at the
  previous and next scan lines.  if there is a point above the start and below the end then we are crossing the line
  if there is a point below the start and above the end then we are crossing the line
  if the start and end are both above or both below then we are not crossing the line

  """

  def count_interior_cells(graph) do
    max_row = graph |> Map.keys() |> Enum.map(fn {row, _} -> row end) |> Enum.max()
    IO.inspect(max_row, label: "max_row")
    Enum.reduce(0..max_row, 0, fn row, acc ->
      wall_indices = find_walls(graph, row)
      IO.inspect(wall_indices, label: "wall_indices")
      acc + scan_line(wall_indices, graph, row)
    end)
  end

  @doc """
  Find the walls in a row
  scan the coordinates in the graph and filter for the row
  then list and sort the columns into an array. This is the list of walls in the row

  """
  def find_walls(graph, row) do
    graph
    |> Map.keys()
    |> Enum.filter(fn {r, _} -> r == row end)
    |> Enum.map(fn {_, col} -> col end)
    |> Enum.sort()
    # |> IO.inspect(label: "find_walls")
  end


end
