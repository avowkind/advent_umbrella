defmodule Advent17Test do
  use ExUnit.Case
  # doctest Advent17

  # test "parse_file" do
  #   assert Advent17.parse_file("data/test22.txt") == %{
  #     0 => 4,
  #     1 => 3,
  #   }
  # end


  # @tag :skip
  test "build_graph" do
    assert Advent17.parse_file("data/test33.txt") |> Advent17.build_graph()
    == %{
      {0, 0} => [
        {{0, 1}, 1, :r},
        {{1, 0}, 3, :d}
      ],
      {0, 1} => [
        {{0, 0}, 2, :l},
        {{0, 2}, 4, :r},
        {{1, 1}, 2, :d}
      ],
      {0, 2} => [
        {{0, 1}, 1, :l},
        {{1, 2}, 1, :d}
      ],
      {1, 0} => [
        {{0, 0}, 2, :u},
        {{1, 1}, 2, :r},
        {{2, 0}, 3, :d}
      ],
      {1, 1} => [
        {{1, 0}, 3, :l},
        {{0, 1}, 1, :u},
        {{1, 2}, 1, :r},
        {{2, 1}, 2, :d}
      ],
      {1, 2} => [
        {{1, 1}, 2, :l},
        {{0, 2}, 4, :u},
        {{2, 2}, 5, :d}
      ],
      {2, 0} => [
        {{1, 0}, 3, :u},
        {{2, 1}, 2, :r}
      ],
      {2, 1} => [
        {{2, 0}, 3, :l},
        {{1, 1}, 2, :u},
        {{2, 2}, 5, :r}
      ],
      {2, 2} => [
        {{2, 1}, 2, :l},
        {{1, 2}, 1, :u}
      ]
    }
  end


  @tag :skip
  test "shortest_path_33" do
    map = Advent17.parse_file("data/test33.txt")
    graph = map |> Advent17.build_graph()

    start = { {0, 0}, 2}
    goal = { 2, 2}
    path = Advent17.shortest_path(graph, start, goal)
    assert path ==
      [
        {0, 0},
        {0, 1},
        {1, 1},
        {1, 2},
        {2, 2}
      ]
    assert Advent17.score_path(path, map) == {11, 5}
  end

  # @tag :skip
  test "shortest_path_55" do
    map = Advent17.parse_file("data/test55.txt")
    graph = map |> Advent17.build_graph()

    start = { {0, 0}, 2}
    goal = { 4,4}
    path = Advent17.shortest_path(graph, start, goal)
    IO.inspect(path, label: "path")
    assert Advent17.score_path(path, map) == {11, 5}
  end
  @tag :skip
  test "shortest_path_test" do
    map = Advent17.parse_file("data/test.txt")
    graph = map |> Advent17.build_graph()

    start = { {0, 0}, 2}
    goal = { 12, 12}
    path = Advent17.shortest_path(graph, start, goal)
    { score, _ } = Advent17.score_path(path, map)
    assert score == 102
  end
end
