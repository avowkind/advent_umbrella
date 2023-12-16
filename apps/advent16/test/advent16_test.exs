defmodule Advent16Test do
  use ExUnit.Case
  doctest Advent16

  # test "rules" do
  #   assert Advent16.apply_rule({:left, 15}, '.', 10) == [{:left, 14}]
  #   assert Advent16.apply_rule({:right, 15}, '.', 10) == [{:right, 16}]
  #   assert Advent16.apply_rule({:up, 15}, '.', 10) == [{:up, 5}]
  #   assert Advent16.apply_rule({:down, 15}, '.', 10) == [{:down, 25}]


  #   assert Advent16.apply_rule({:up, 15}, '|', 10) == [{:up, 5}]
  #   assert Advent16.apply_rule({:left, 15}, '|', 10) == [{:up, 5}, {:down, 25}]
  #   assert Advent16.apply_rule({:right, 15}, '/', 10) == [{:up, 5}]
  #   assert Advent16.apply_rule({:left, 15}, '/', 10) == [{:down, 25}]
  #   assert Advent16.apply_rule({:down, 15}, '-', 10)  == [{:left, 14}, {:right, 16}]
  #   assert Advent16.apply_rule({:left, 15}, '\\', 10)  == [{:up, 5}]
  #   assert Advent16.apply_rule({:right, 15}, '\\', 10)  == [{:down, 25}]

  #   # off map tests
  #   assert Advent16.apply_rule({:up, 0}, '.', 10) == [{:out, -10}]
  #   assert Advent16.apply_rule({:left, 0}, '.', 10) == [{:out, -1}]

  #   assert Advent16.apply_rule({:right, 9}, '.', 10) == [{:out, 10}]
  #   assert Advent16.apply_rule({:right, 19}, '.', 10) == [{:out, 20}]
  #   assert Advent16.apply_rule({:left, 10}, '.', 10) == [{:out, 9}]
  #   assert Advent16.apply_rule({:left, 20}, '.', 10) == [{:out, 19}]
  #   assert Advent16.apply_rule({:up, 9}, '.', 10) == [{:out, -1}]
  #   assert Advent16.apply_rule({:down, 99}, '.', 10) == [{:out, 109}]
  #   assert Advent16.apply_rule({:right, 99}, '.', 10) == [{:out, 100}]
  #   assert Advent16.apply_rule({:down, 90}, '.', 10) == [{:out, 100}]
  #   assert Advent16.apply_rule({:down, 91}, '.', 10) == [{:out, 101}]
  # end

  # test "ray_trace cycle " do
  #   IO.puts("test ray_trace mini")
  #   map = "data/cycle.txt" |> Advent16.parse_file()
  #   Advent16.ray_trace([], {:right, 0}, 4,  map)
  #   |> IO.inspect(label: "map")
  #   |> Advent16.count_pos()
  #   |> IO.inspect(label: "count")
  # end

  # test "ray_trace" do
  #   IO.puts("test ray_trace")
  #   map = "data/test.txt" |> Advent16.parse_file()
  #   Advent16.ray_trace([], {:right, 0}, map)
  #   |> IO.inspect(label: "map")
  #   |> Advent16.count_pos()
  #   |> IO.inspect(label: "count")
  # end

  # @tag timeout: 360000
  # test "part 1" do
  #   IO.puts("test ray_trace")
  #   map = "data/data.txt" |> Advent16.parse_file()
  #   Advent16.ray_trace([], {:right, 0}, map)
  #   |> Advent16.count_pos()
  #   |> IO.inspect(label: "count")
  # end

  # @tag timeout: 360000
  # test "part 2" do
  #   Advent16.run2("data/data.txt")
  #   |> IO.inspect(label: "count")
  # end

  @tag timeout: 360000
  test "part 3" do
    Advent16.run3("data/data.txt")
    |> IO.inspect(label: "count")
  end
end
