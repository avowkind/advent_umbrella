defmodule Advent8Test do
  use ExUnit.Case
  doctest Advent8



  test "parse_test_data" do
    assert Advent8.parse_lines("data/test.txt")
      == {
        [:R, :L],
        %{
          "AAA" => {"BBB", "CCC"},
          "BBB" => {"DDD", "EEE"},
          "CCC" => {"ZZZ", "GGG"},
          "DDD" => {"DDD", "DDD"},
          "EEE" => {"EEE", "EEE"},
          "GGG" => {"GGG", "GGG"},
          "ZZZ" => {"ZZZ", "ZZZ"}
        }
      }
  end


  test "follow test" do
    assert Advent8.parse_lines("data/test.txt")
      |> Advent8.follow()
      |> IO.inspect()
      == 2
  end

  # test "follow test to z" do
  #   assert Advent8.parse_lines("data/test.txt")
  #     |> Advent8.follow_to_z()
  #     |> IO.inspect()
  #     == 2
  # end
  test "follow data to z" do
    assert Advent8.parse_lines("data/data.txt")
      |> Advent8.follow_to_z()
      |> IO.inspect()
      |> Enum.map( fn {_, count} -> count end)
      # |> IO.inspect()
      |> Enum.reduce( &(Math.lcm(&1, &2)))
      |> IO.inspect()

  end

  # test "follow data" do
  #   assert Advent8.parse_lines("data/data.txt")
  #     |> Advent8.follow()
  #     |> IO.inspect()
  #     == 18113
  # end

  test "ends_in_a" do
    { _, map } = Advent8.parse_lines("data/data.txt")
    as = map |> Advent8.ends_in("A")
      |> IO.inspect()
      |> length()
    assert as == 6
  end
  test "ends_in_z" do
    { _, map } = Advent8.parse_lines("data/data.txt")
    as = map |> Advent8.ends_in("Z")
      |> IO.inspect()
      |> length()
    assert as == 6
  end

  # @tag timeout: :infinity
  # test "follow real data 2" do
  #   assert Advent8.parse_lines("data/data.txt")
  #     |> Advent8.follow3()
  #     |> IO.inspect()
  #     == 6
  # end
end
