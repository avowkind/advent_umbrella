defmodule Advent1Test do
  use ExUnit.Case
  doctest Advent1

  test "match_first" do
    assert Advent1.match_first("")  == :no_match
    assert Advent1.match_first("0")  == 0
    assert Advent1.match_first("xxxx")  == :no_match
    assert Advent1.match_first("zero")  == :no_match
    assert Advent1.match_first("1") == 1
    assert Advent1.match_first("one") == 1
    assert Advent1.match_first("one1") == 1
    assert Advent1.match_first("aone1two") == 1
    assert Advent1.match_first("21two2") == 2
    assert Advent1.match_first("twoone1two2three") == 2
    assert Advent1.match_first("sfafnineasdf") == 9
    assert Advent1.match_first("two1nine") == 2
    assert Advent1.match_first("eightwothree") == 8
    assert Advent1.match_first("abcone2threexyz") == 1
    assert Advent1.match_first("xtwone3four") == 2
    assert Advent1.match_first("4nineeightseven2") == 4
    assert Advent1.match_first("zoneight234") == 1
    assert Advent1.match_first("7pqrstsixteen") == 7
    assert Advent1.match_first("sevenine") == 7

  end

  test "match_last" do
    assert Advent1.match_last("1") == 1
    assert Advent1.match_last("one") == 1
    assert Advent1.match_last("one1") == 1
    assert Advent1.match_last("aone1two") == 2
    assert Advent1.match_last("21two2") == 2
    assert Advent1.match_last("twoone1two2three") == 3
    assert Advent1.match_last("sfafnineasdf") == 9
    assert Advent1.match_last("two1nine") == 9
    assert Advent1.match_last("eightwothree") == 3
    assert Advent1.match_last("abcone2threexyz") == 3
    assert Advent1.match_last("xtwone3four") == 4
    assert Advent1.match_last("4nineeightseven2") == 2
    assert Advent1.match_last("zoneight234") == 4
    assert Advent1.match_last("7pqrstsixteen") == 6
    assert Advent1.match_last("sevenine") == 9

  end

  test "find_digits" do
    assert Advent1.find_digits("12a34") == 14
    assert Advent1.find_digits("12aa345") == 15
    assert Advent1.find_digits("aa123456aa") == 16
    assert Advent1.find_digits("a1b23456c7d") == 17
    assert Advent1.find_digits("one1xtwo") == 12
    assert Advent1.find_digits("sevenine") == 79
    assert Advent1.find_digits("vj3") == 33
    assert Advent1.find_digits("oneight") == 18
    assert Advent1.find_digits("xxxx") == 0
    assert Advent1.find_digits("one") == 11


  end

  test "sum the coordinates" do
    total = Advent1.readfile("data/data.txt")
    IO.puts("Total: #{total}")
    assert total == 54530
  end
end
