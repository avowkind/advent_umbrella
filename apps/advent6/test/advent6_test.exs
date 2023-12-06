defmodule Advent6Test do
  use ExUnit.Case
  doctest Advent6

  test "parse_line" do
    Advent6.parse_line("Time:        48     87     69     81", %{})
    # IO.inspect(x, charlists: :as_lists)
  end

  test "parse_test" do
    x = Advent6.test_file()
    |> Advent6.parse_file()
    # IO.inspect(x, charlists: :as_lists)
    assert x == [{7, 9}, {15, 40}, {30, 200}]
  end

  test "parse_data" do
    assert Advent6.data_file() |> Advent6.parse_file()
      == [{48, 255}, {87, 1288}, {69, 1117}, {81, 1623}]
  end

  test "distance_travelled" do
    assert Advent6.distance_travelled(1,7) == 6
    assert Advent6.distance_travelled(2,7) == 10
    assert Advent6.distance_travelled(3,7) == 12
    assert Advent6.distance_travelled(4,7) == 12
    assert Advent6.distance_travelled(5,7) == 10
    assert Advent6.distance_travelled(6,7) == 6
  end
  test "calc_race" do
    assert Advent6.calc_race({7, 9}) == 4
  end
  test "calc_races" do
    assert Advent6.test_file()
    |> Advent6.parse_file()
    |> Advent6.calc_races()
    |> IO.inspect()
    == 288
  end
  test "data calc_races" do
    assert Advent6.data_file()
    |> Advent6.parse_file()
    |> Advent6.calc_races()
    |> IO.inspect()
    == 252000
  end

  test "calc_races2" do
    assert File.stream!("data/test2.txt")
    |> Advent6.parse_file()
    |> Advent6.calc_races()
    |> IO.inspect()
    == 71503
  end

  test "data calc_races2" do
    assert File.stream!("data/data2.txt")
    |> Advent6.parse_file()
    |> Advent6.calc_races()
    |> IO.inspect()
    == 36992486
  end

  test "press_times" do
    assert Advent6.calc_race3({7, 9}) == 4
  end

  test "calc_races3" do
    assert File.stream!("data/test2.txt")
    |> Advent6.parse_file()
    |> Advent6.calc_races3()
    |> IO.inspect()
    == 71503
  end

  test "data calc_races3" do
    assert File.stream!("data/data2.txt")
    |> Advent6.parse_file()
    |> Advent6.calc_races3()
    |> IO.inspect()
    == 36992486
  end
end
