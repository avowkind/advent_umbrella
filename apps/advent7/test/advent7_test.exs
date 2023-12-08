defmodule Advent7Test do
  use ExUnit.Case
  doctest Advent7

  # test "parse_line" do
  #   assert Advent7.parse_line("32T3K 765") == {"32T3K", 765}
  # end

  test "parse_file test.txt" do
    lines = Advent7.parse_file("data/test.txt")
    assert length(lines) == 5
  end

  test "sort_hand" do
    assert Advent7.sort_hand("32T3K") == [{1, 2}, {11, 1}, {8, 1}, {0, 1}]
    assert Advent7.sort_hand("T55J5") == [{3, 3}, {9, 1}, {8, 1}]
    assert Advent7.sort_hand("KK677") == [{11, 2}, {5, 2}, {4, 1}]
  end

  test "rank_hand" do
    assert Advent7.name_rank("32T3K") == :one_pair
    assert Advent7.name_rank("T55J5") == :three_of_a_kind
    assert Advent7.name_rank("KK677") == :two_pair
    assert Advent7.name_rank("KTJJT") == :two_pair
    assert Advent7.name_rank("KKK77") == :full_house
    assert Advent7.name_rank("KK7KK") == :four_of_a_kind
    assert Advent7.name_rank("AAAAK") == :four_of_a_kind
    assert Advent7.name_rank("AAAAA") == :five_of_a_kind
    assert Advent7.name_rank("AAABB") == :full_house
    assert Advent7.name_rank("12345") == :high_card
  end

  test "hand_strength" do
    assert Advent7.hand_strength("22222") == 0
    assert Advent7.hand_strength("22223") == 1
    assert Advent7.hand_strength("222A2") == 12 * 13
    assert Advent7.hand_strength("AAAAA") == 13 ** 5 - 1

  end

  test "order hands" do
    x = Advent7.parse_file("data/test.txt")
    |> Advent7.order_hands()
    |> IO.inspect()
    assert x = 6440
  end

  test "part one" do
    x = Advent7.parse_file("data/data.txt")
    |> Advent7.order_hands()
    |> IO.inspect()
    assert x = 6440
  end
end
