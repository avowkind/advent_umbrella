defmodule Advent6 do
  @moduledoc """
  Documentation for `Advent6`.
  """

  def data_file() do
    File.stream!("data/data.txt")
  end
  def test_file() do
    File.stream!("data/test.txt")
  end
  def line_to_integers(line) do
    String.split(String.trim(line), " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_line(line, acc) do
    [key | rest_of_line] = String.split(line, ":")
    key = String.trim(key)
    values = line_to_integers(hd(rest_of_line))
    case key do
      "Time" ->
        Map.put(acc, :time, values)
      "Distance" ->
        Map.put(acc, :distance, values)
      _ -> acc
    end
  end

  # zip the time and distance lists together
  def zip_time_distance(%{time: time, distance: distance}) do
    Enum.zip(time, distance)
  end

  def parse_file(stream) do
    zip_time_distance(Enum.reduce(stream, %{}, &parse_line( &1, &2)))
  end

  @doc """
  Calculates the distance traveled for a given millisecond

  """
  def distance_travelled press_time, race_time do
    press_time * (race_time - press_time)
  end

  # end
  def calc_race({time, distance}) do
    # iterate from 1 to time
    # for each ms, calculate the distance traveled
    # return the max distance traveled
    Enum.map(1..time-1, fn(ms) ->
      distance_travelled(ms, time)
    end)
    |> Enum.count(fn(x) -> x > distance end)
    # |> IO.inspect()
  end

  def calc_races(races) do
    races |> Enum.map(&calc_race(&1))
    # |> IO.inspect()
    |> Enum.product()
  end

  def calc_race3({time, distance}) do
    part1 = -time / -2
    part2 = :math.sqrt(time * time - 4 * distance) / 2
    :math.floor(part1 + part2) - :math.floor(part1 - part2)
  end

  def calc_races3(races) do
    races |> Enum.map(&calc_race3(&1))
    # |> IO.inspect()
    |> Enum.product()
  end
end
