defmodule Advent1 do
  @moduledoc """
  Documentation for `Advent1`.
  """

  @word_to_digit %{
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
  }
  @words ~w(one two three four five six seven eight nine)
  @rwords ["eno", "owt", "eerht", "ruof", "evif", "xis", "neves", "thgie", "enin"]
  @first_number ~r/\d|one|two|three|four|five|six|seven|eight|nine/
  @last_number ~r/\d|eno|owt|xis|enin|ruof|evif|eerht|neves|thgie/

  def match_first(string) do
    match = Regex.run(@first_number, string)
    case match do
      nil -> :no_match
      [digit] when digit in @words -> @word_to_digit[digit]
      [digit] -> String.to_integer(digit)
    end
  end

  def match_last(string) do
    match = Regex.run(@last_number, String.reverse(string))
    case match do
      nil -> :no_match
      [digit] when digit in @rwords -> @word_to_digit[String.reverse(digit)]
      [digit] -> String.to_integer(digit)
    end
  end
  #
  def  (string) do
    first_digit = string |> match_first()
    last_digit = string |> match_last()
    case {first_digit, last_digit} do
      {:no_match, :no_match} -> 0
      {:no_match, last_digit} -> last_digit*10 + last_digit
      {first_digit, :no_match} -> first_digit*10 + first_digit
      {first_digit, last_digit} -> first_digit*10 + last_digit
    end
  end

  def readfile(filename) do
    File.stream!(filename)
    |> Enum.reduce(0, fn line, acc ->
      line
      |> String.trim()
      |> find_digits()
      |> Kernel.+(acc)
    end)

  end


end
