defmodule Advent18Test do
  use ExUnit.Case
  # doctest Advent18
  doctest Advent18a

  @tag :skip
  test "run_test" do
    graph = Advent18.parse_file("data/test.txt")
    |> IO.inspect(label: "parse_data")
    |> Advent18.build_graph({0,0})
    |> IO.inspect(label: "build_graph")
    graph |> Advent18.draw_graph()
    # walls = graph |> Map.keys() |> Enum.count()
    graph |> Advent18.count_interior_cells()
    |> IO.inspect(label: "count_interior_cells")
  end

  @tag :skip
  test "parse_data" do
    Advent18.parse_file("data/data.txt")
    |> IO.inspect(label: "parse_data")
  end

  @tag :skip
  test "run_data" do
    graph = Advent18.parse_file("data/data.txt")
    |> IO.inspect(label: "parse_data")
    |> Advent18.build_graph({0,0})
    |> IO.inspect(label: "build_graph")

    # graph |> Advent18.draw_graph()
    walls = graph |> Map.keys() |> Enum.count()
    interior = graph |> Advent18.count_interior_cells()
    |> IO.inspect(label: "count_interior_cells")
    walls + interior |> IO.inspect(label: "walls + interior")

  end


  test "run_test 2" do
    graph = Advent18a.parse_file2("data/data.txt")
    { graph, acc } = Advent18a.reduce_rects(graph)
    Advent18a.reduce_rects(graph, acc)
    |> IO.inspect()
    |> Advent18a.sum_rects()
  end

  # 31549263 * 32855156  = 1,036,555,957,550,028
  # 946396987969229 too hight
end
