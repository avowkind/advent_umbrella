defmodule Advent17 do
  @moduledoc """
  Documentation for `Advent17`.
  """


  @doc """
  Parsing
  read each line into a number array.
  Example:

  it can move at most three blocks in a single direction before
  it must turn 90 degrees left or right

          iex> Advent17.parse_line("2413432311323", 1)
  """
  def parse_line(line, row) do
    line
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index(0)  # Add an index starting from 1 to each element
    |> Enum.map(fn {ch, col} -> {{row,col}, String.to_integer(ch)} end)  # Convert each element to a tuple
    # |> IO.inspect(label: "parse_line #{row}")
  end

  @doc """
  Parsing
  read each line into a coordinate map
  Example:

          iex> Advent17.parse_file("data/test33.txt")
          %{
            {0, 0} => 2,
            {0, 1} => 1,
            {0, 2} => 4,
            {1, 0} => 3,
            {1, 1} => 2,
            {1, 2} => 1,
            {2, 0} => 3,
            {2, 1} => 2,
            {2, 2} => 5
          }
  """
  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.with_index(0)  # Add an index starting from 1 to each element
    |> Enum.flat_map(fn {line, row} -> parse_line(line, row) end)  # Convert each element to a tuple
    |> Enum.into(%{})  # Convert the result to a map
    # |> IO.inspect(label: "parse_file")

  end

  @doc """
  Build Graph

  Given the map of coordinates and scores build a graph of the possible moves
  in this version we  allow moves up, down, left and right but not off the map
  """
  def build_graph(map) do
    map
    |> Enum.reduce(%{},
      fn {{row, col}, _}, acc ->
        links_to = Enum.reduce([ {:d, row+1, col}, {:r, row, col+1}, {:u, row-1, col}, {:l, row, col-1}], [],
          fn { dir, r, c}, edges ->
            if Map.has_key?(map, {r,c}) do
              cost = Map.get(map, {r,c})
              [{{r,c}, cost, dir} | edges]
            else
              edges
            end
          end)
        Map.put(acc, {row, col}, links_to)
      end)
  end

  @doc """
  Dijkstra's algorithm finding shortest path.
  https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
  """
  def shortest_path(graph, start, goal) do
    { first, cost } = start
    shortest_path(graph, start, goal,
      MapSet.new([first]), # open_set
      %{},   # came_from
      %{},   # g_score
      first, # starting pos = currenct
      cost, # cost = current_score
      %{} # direction_counts
    )
  end
  # def shortest_path(graph, start, goal) do
  #   { first, cost } = start
  #   shortest_path(graph, start, goal, MapSet.new([first]), %{}, %{}, first, cost)
  # end
  defp shortest_path(graph, start, goal, open_set, came_from, g_score, current, current_score, direction_counts, last_direction \\ nil) do
    IO.inspect({ start, open_set, came_from, g_score, current, current_score, direction_counts}, label: "\n\nshortest_path")

    if current == goal do
      IO.puts('found goal')
      reconstruct_path(came_from, current)
      |> IO.inspect(label: "result path")
    else
      g_score = Map.put(g_score, current, current_score)
      open_set = MapSet.delete(open_set, current)

      neighbours = Map.get(graph, current, [])
      IO.inspect(neighbours, label: "neighbours")
      {open_set, came_from, g_score, direction_counts, last_direction} =
        Enum.reduce(neighbours, {open_set, came_from, g_score, direction_counts, last_direction},
          fn {neighbour, cost, dir}, {acc_open_set, acc_came_from, acc_g_score, acc_direction_counts, acc_last_direction} ->
            IO.inspect({neighbour, cost, dir}, label: "reduce neighbour [")
            tentative_g_score = Map.get(acc_g_score, current) + cost
            neighbour_g_score = Map.get(acc_g_score, neighbour, :infinity)
            direction_count = if dir == acc_last_direction, do: Map.get(acc_direction_counts, dir, 0), else: 0
            IO.inspect({direction_count, direction_counts}, label: "direction_count")
            if tentative_g_score < neighbour_g_score and direction_count < 3 do
              acc_came_from = Map.put(acc_came_from, neighbour, current)
              acc_g_score = Map.put(acc_g_score, neighbour, tentative_g_score)
              acc_open_set = MapSet.put(acc_open_set, neighbour)
              acc_direction_counts = if dir == acc_last_direction, do: Map.put(acc_direction_counts, dir, direction_count + 1), else: %{dir => 1}
              IO.inspect({neighbour, cost, acc_direction_counts}, label: "] reduce neighbour <")
              {acc_open_set, acc_came_from, acc_g_score, acc_direction_counts, dir}
            else
              IO.inspect({neighbour, cost, acc_direction_counts}, label: "] reduce neighbour >=")
              {acc_open_set, acc_came_from, acc_g_score, acc_direction_counts, acc_last_direction}
            end
          end)

      if MapSet.size(open_set) > 0 do
        IO.inspect(open_set, label: "\nopen_set")
        current = Enum.min_by(open_set, &Map.get(g_score, &1, :infinity))
        IO.inspect(current, label: "current")
        current_score = Map.get(g_score, current)
        shortest_path(graph, start, goal, open_set, came_from, g_score, current, current_score, direction_counts, last_direction)
      else
        :no_path
      end
    end
  end


  # defp shortest_path(graph, start, goal, open_set, came_from, g_score, current, current_score) do
  #   IO.inspect({ start, open_set, came_from, g_score, current, current_score}, label: "shortest_path")
  #   if current == goal do
  #     IO.puts('found goal')
  #     reconstruct_path(came_from, current)
  #     |> IO.inspect(label: "result path")
  #   else
  #     g_score = Map.put(g_score, current, current_score)
  #     IO.inspect(g_score, label: "g_score")
  #     open_set = MapSet.delete(open_set, current)
  #     IO.inspect(open_set, label: "open_set")
  #     neighbours = Map.get(graph, current, [])
  #     IO.inspect(neighbours, label: "neighbours")

  #     {open_set, came_from, g_score} =
  #       Enum.reduce(neighbours, {open_set, came_from, g_score},
  #       fn {neighbour, cost, dir}, {acc_open_set, acc_came_from, acc_g_score} ->
  #         IO.inspect({neighbour, cost, dir}, label: "reduce neighbour")
  #         tentative_g_score = Map.get(acc_g_score, current) + cost
  #         neighbour_g_score = Map.get(acc_g_score, neighbour, :infinity)
  #         if tentative_g_score <  neighbour_g_score do
  #           IO.puts("tentative_g_score < neighbour_g_score")
  #           acc_came_from = Map.put(acc_came_from, neighbour, current)
  #           acc_g_score = Map.put(acc_g_score, neighbour, tentative_g_score)
  #           acc_open_set = MapSet.put(acc_open_set, neighbour)
  #           {acc_open_set, acc_came_from, acc_g_score}
  #         else
  #           {acc_open_set, acc_came_from, acc_g_score}
  #         end
  #       end)

  #     if MapSet.size(open_set) > 0 do
  #       IO.puts("MapSet.size(open_set) > 0")
  #       IO.inspect(open_set, label: "open_set")
  #       current = Enum.min_by(open_set, &Map.get(g_score, &1, :infinity))
  #       IO.inspect(current, label: "current")
  #       current_score = Map.get(g_score, current)
  #       IO.inspect(current_score, label: "current_score")

  #       shortest_path(graph, start, goal, open_set, came_from, g_score, current, current_score)
  #     else
  #       :no_path
  #     end
  #   end
  # end

  defp reconstruct_path(came_from, current, path \\ []) do
    path = [ current | path]
    if Map.has_key?(came_from, current) do
      reconstruct_path(came_from, Map.get(came_from,current), path)
    else
      path
    end
  end

  def score_path(path, map) do
    IO.inspect(path, label: "score_path")
    total_cost = Enum.reduce(path, 0,
      fn pos, acc ->
        acc + Map.get(map, pos)
      end)
    steps = Enum.count(path)
    {total_cost, steps}
  end
end
