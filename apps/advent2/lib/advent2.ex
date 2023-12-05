defmodule Advent2 do
  @moduledoc """
  Documentation for `Advent2`.
  """
  @doc """
  Parses a string of game id
  e.g "Game 12"
  regex the number from the string and convert to int
  """
  @spec get_game_id(String.t()) :: {:no_match} | integer
  def get_game_id(game) do
    match = Regex.run(~r/Game (\d+)/, game)
    case match do
      nil -> :no_match
      [_, id] -> String.to_integer(id)
    end
  end

  @doc """
  Parses a string of colour/count into a tuple { atom, integer}
  e.g "3 blue"
  regex the number and colour
  """
  @spec get_colour_count(String.t()) :: {:no_match} | {atom, integer}
  def get_colour_count(cubes) do
    # match = Regex.run(~r/(\d+) (\w+)/, String.trim(colour))
    # case match do
    #   nil -> :no_match
    #   [_, count, colour] ->{String.to_atom(colour), String.to_integer(count)}
    # end
    # use String.split instead of regex
    [count, color] = String.split(String.trim(cubes), " ")
    {String.to_atom(color), String.to_integer(count)}
  end

  @doc """
  Parses a string of colours
  e.g "3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
  split into groups on ; then split each into colour/count pairs
  convert the colour to an atom and the count to an integer.
  add the result to a map
  """
  @spec parse_picks(String.t()) :: [{map}]
  def parse_picks(colours_str) do
    colour_groups = String.split(colours_str, ";")
    Enum.map(colour_groups,
      fn colour_str ->
        String.split(colour_str, ",")
        |> Enum.map(&get_colour_count/1)
        |> Enum.into(%{})
      end
    )
  end

  @doc """
  Parses a line of the file
  e.g "Game 12: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
  split into game and picks
  """
  def parse_line( line ) do
    # [game, picks] = String.split(line, ":")
    ["Game " <> id, picks] = String.trim(line) |> String.split(": ")

    %{
      id: String.to_integer(id),
      picks: parse_picks(picks)
    }
  end

  @doc """
  Returns true if the cube is out of bounds
  """
  @spec check_cube?(atom, integer) :: boolean
  def check_cube?(colour, count) do
    max = %{ red: 12, green: 13, blue: 14}
    count > max[colour]
  end

  @doc """
  Returns true if the game is out of bounds
  """
  @spec check_game(map) :: boolean
  def check_game(game) do
    Enum.reduce(game.picks, false, fn pick, acc ->
      acc or Enum.reduce(pick, false, fn {colour, count}, acc ->
        acc or check_cube?(colour, count)
      end)
    end)
  end


  @doc """
  Returns the sum of the ids of the games that are not out of bounds
  """
  @spec check_cubes() :: integer
  def check_cubes() do
    File.stream!("data/data.txt")
    |> Enum.map(&parse_line(&1))
    |> Enum.reject(&check_game(&1))
    |> Enum.map(fn game -> game.id end)
    |> Enum.sum()
  end

  ### Part 2

  @doc """
  returns sum of the product of the max of each colour pick
  """
  @spec check_game_power(map) :: integer()
  def check_game_power(game) do
    Enum.reduce(game.picks, %{}, fn pick, acc ->
      # find the max of each colour pick
      Map.merge(pick, acc, fn _k, v1, v2 -> max(v1, v2) end)
      # Enum.reduce(pick, acc, fn {colour, count}, acc ->
      #   case colour do
      #     :red -> %{ acc | red: max(acc.red, count)}
      #     :green -> %{ acc | green: max(acc.green, count)}
      #     :blue -> %{ acc | blue: max(acc.blue, count)}
      #   end
      # end)
    end)
    |> Map.values()
    |> Enum.product()
  end

  @doc """
  Returns the sum of the game powers
  """
  @spec check_powers() :: integer
  def check_powers() do
    File.stream!("data/data.txt")
    |> Stream.map(&parse_line(&1))
    # |> Enum.reject(&check_game(&1))
    |> Enum.map(&check_game_power(&1))
    |> Enum.sum()
  end

end
