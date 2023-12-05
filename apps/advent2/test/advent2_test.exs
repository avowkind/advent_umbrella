defmodule Advent2Test do
  use ExUnit.Case
  doctest Advent2

  @games [
  "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
  "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
  "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
  "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
  "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
  ]

  test "get_game_id" do
    assert Advent2.get_game_id("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == 1
    assert Advent2.get_game_id("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue") == 2
    assert Advent2.get_game_id("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red") == 3
    assert Advent2.get_game_id("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red") == 4
    assert Advent2.get_game_id("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green") == 5
  end

  test "get_colour_count" do
    assert Advent2.get_colour_count("3 blue") == {:blue, 3}
    assert Advent2.get_colour_count("14 red") == {:red, 14}
    assert Advent2.get_colour_count(" 14 red ") == {:red, 14}
  end

  test "parse_picks" do
    assert Advent2.parse_picks("3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == [
      %{blue: 3, red: 4},
      %{red: 1, green: 2, blue: 6},
      %{green: 2}
    ]
    assert Advent2.parse_picks("1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue") == [
      %{blue: 1, green: 2},
      %{green: 3, blue: 4, red: 1},
      %{green: 1, blue: 1}
    ]
  end
  test "parse_line" do
    [line| _] = @games
    assert Advent2.parse_line(line) == %{
        id: 1,
        picks: [
          %{ blue: 3, red: 4 },
          %{ red: 1, green: 2, blue: 6 },
          %{ green: 2 }
        ]
      }
  end

  test "check_cube?" do
    assert Advent2.check_cube?(:red, 12) == false
    assert Advent2.check_cube?(:red, 13) == true
    assert Advent2.check_cube?(:red, 14) == true
    assert Advent2.check_cube?(:green, 12) == false
    assert Advent2.check_cube?(:green, 13) == false
    assert Advent2.check_cube?(:green, 14) == true
    assert Advent2.check_cube?(:blue, 13) == false
    assert Advent2.check_cube?(:blue, 14) == false
    assert Advent2.check_cube?(:blue, 15) == true
  end

  test "check_game" do
    game = %{
      id: 1,
      picks: [
        %{ blue: 3, red: 4 },
        %{ red: 1, green: 2, blue: 6 },
        %{ green: 2 }
      ]
    }
    assert Advent2.check_game(game) == false

    game = %{
      id: 2,
      picks: [
        %{ blue: 15, red: 4 },
        %{ red: 1, green: 2, blue: 6 },
        %{ green: 2 }
      ]
    }
    assert Advent2.check_game(game) == true

    game = %{
      id: 3,
      picks: [
        %{ blue: 12, red: 4 },
        %{ red: 1, green: 1, blue: 6 },
        %{ green: 14 }
      ]
    }
    assert Advent2.check_game(game) == true
    game = %{
      id: 4,
      picks: [
        %{ red: 13, green: 1, blue: 6 },
      ]
    }
    assert Advent2.check_game(game) == true
  end

  test "check_cubes" do
    assert Advent2.check_cubes() == 2256
  end

  # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green = 48
  test "power" do
    results = @games |> Enum.map(fn line ->
      Advent2.parse_line(line) |> Advent2.check_game_power()
    end)

    assert results == [48, 12, 1560, 630, 36]
  end

  test "powers" do
    assert Advent2.check_powers() == 74229
  end
end
