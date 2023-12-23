defmodule Advent19Test do
  use ExUnit.Case
  # doctest Advent19

  # test "parse_file" do
  #   "data/test.txt" |> Advent19.parse_file() |> IO.inspect()
  # end

  # test "process_workflow"  do
  #   { workflows, ratings } = "data/test.txt"
  #   |> Advent19.parse_file()
  #   # [rating | _ ] = ratings
  #   # assert Advent19.process_rating(rating, workflows) == {:A, %{s: 2876, a: 1222, m: 2655, x: 787}}
  #   ratings
  #   |> Enum.map(fn rating ->
  #     Advent19.process_rating(rating, workflows)
  #   end)
  #   |> IO.inspect(label: 'ratings')
  # end

  # test "run"  do
  #   IO.puts("part 1")
  #   # { workflows, ratings } = "data/test.txt" |>
  #   Advent19.run("data/data.txt")
  #   |> IO.inspect(label: 'run ratings')
  # end

  test "find_a_ranges" do
    { workflows, _ratings } = "data/test.txt"
    |> Advent19.parse_file()
    Advent19.find_A_ranges(workflows)
    |> IO.inspect(label: 'find_A_ranges result', limit: :infinity)
  end
end
