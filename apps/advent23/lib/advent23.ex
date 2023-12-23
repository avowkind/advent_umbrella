defmodule Advent23 do
  @moduledoc """
  Documentation for `Advent23`.
  """

  def add_edges(graph, edges, row, col, ch, directions) do
    # check Up down left right for other graph members and
    # add to the list of links.
    # IO.inspect({row, col, edges, graph},label: "add_edges (")
    Enum.reduce(directions, edges, fn {{r, c},dir}, acc ->
      if Map.has_key?(graph, {r, c})
        and Map.get(graph, {r, c}) != dir do
        # IO.inspect({{r, c}, Map.get(graph, {r, c}), dir}, label: "add_edge")
        # add link in both directions
        case ch do
          :right ->
            [{{r, c}, {row, col}} | acc]
          :down ->
            [{{r, c}, {row, col}} | acc]
          _ -> # add back link
            acc = [{{row, col}, {r, c}} | acc]
            [{{r, c}, {row, col}} | acc]
        end
      else
        acc
      end
    end)
    # |> IO.inspect(label: ")add_edges")
  end

  @doc """
  read line into to graph
  """
  def graphify({line, row}, ge) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(ge, fn {char, col}, {graph,edges} ->
      directions = [{{row-1, col},:right}, {{row, col-1},:down}]
      case char do
        "." ->
          { Map.put(graph, {row,col}, :dot),
            add_edges(graph, edges, row, col, :dot, directions)}
        ">" ->
          { Map.put(graph, {row,col}, :right),
            add_edges(graph, edges, row, col, :right, directions)}
        "v" ->
          { Map.put(graph, {row,col}, :down),
            add_edges(graph, edges, row, col, :down, directions)}
        _ -> {graph,edges}
      end
    end)
    # |> IO.inspect(label: "graphify")
  end

  @doc """
  read map to graph

  read the strings from the file and create a graph based on the . and > and v characters

  #.#####################
  #.......#########...###
  #######.#########.#.###
  ###.....#.>.>.###.#.###
  ###v#####.#v#.###.#.###
  ###.>...#.#.#.....#...#
  ###v###.#.#.#########.#
  ###...#.#.#.......#...#
  #####.#.#.#######.#.###
  #.....#.#.#.......#...#
  #.#####.#.#.#########v#
  #.#...#...#...###...>.#
  #.#.#v#######v###.###v#
  #...#.>.#...>.>.#.###.#
  #####v#.#.###v#.#.###.#
  #.....#...#...#.#.#...#
  #.#########.###.#.#.###
  #...###...#...#...#.###
  ###.###.#.###v#####v###
  #...#...#.#.>.>.#.>.###
  #.###.###.#.###.#.#v###
  #.....###...###...#...#
  #####################.#

  ## Examples

      iex> Advent23.read_map_to_graph("data/test1.txt")


  """
  def read_map_to_graph(filename) do
    {_graph, edges} = filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce({%{}, []}, &graphify/2)

    Enum.reduce(edges, %{}, fn {{start_row, start_col}, tail}, acc ->
      Map.update(acc, {start_row, start_col}, [tail], fn edge -> edge ++ tail end)
    end)
    |> IO.inspect(label: "read_map_to_graph")
  end

  def topological_sort(graph, start) do
    res = dfs(graph, start, %{ order: [], visited: Map.new()})
    {order, _} = res
    Enum.reverse(order)
  end

  defp dfs(graph, node, acc) do
    IO.puts("dfs")
    order = Map.get(acc, :order)
    visited = Map.get(acc, :visited)
    if Map.get(visited, node, false) do
      IO.inspect({node, order, visited}, label: "true")
      acc
    else
      IO.inspect({node, order, visited, graph[node]}, label: "false")

      acc =
        Enum.reduce(graph[node],
          %{order: order, visited: Map.put(visited, node, true)},
          fn neighbor, acc -> dfs(graph, neighbor, acc)
          end)

      order = Map.get(acc, :order)
      visited = Map.get(acc, :visited)
      IO.inspect({node, order, visited}, label: "after reduce")
      %{order: [node | order], visited: visited}
    end
    |> IO.inspect(label: "dfs end")
  end
  @doc """
  given a graph containing nodes and a list of edges
  we want to find the longest path
    %{
      {0, 1} => [{1, 1}],
      {0, 3} => [{1, 3}],
      {1, 1} => [{1, 2} | {0, 1}],
      {1, 2} => [{1, 3} | {1, 1}],
      {1, 3} => [{2, 3}],
      {2, 3} => [{1, 3}]
    }
  """

  def find_path(graph, start, finish) do
    IO.puts("start sort")
    sorted_nodes = topological_sort(graph, start)
    distances = Map.new(sorted_nodes,
      fn node -> {node, (if node == start, do: 0, else: -1)} end)
    IO.inspect({sorted_nodes, distances}, label: "sorted_nodes")
    Enum.reduce(sorted_nodes, distances, fn node, distances ->
      Enum.reduce(graph[node], distances, fn neighbor, distances ->
        distance_to_neighbor = distances[node] + 1 # assuming all edges have weight 1
        if distance_to_neighbor > distances[neighbor] do
          Map.put(distances, neighbor, distance_to_neighbor)
        else
          distances
        end
      end)
    end)[finish]
  end

  @doc """
    do part 1
    ## Examples

   iex> Advent23.run1("data/test1.txt")

   """
  def run1(filename) do
    IO.puts "Advent23.run"
    graph = read_map_to_graph(filename)
    find_path(graph, {0, 1}, {2, 3})
    |> IO.inspect(label: "run1")
  end

end
