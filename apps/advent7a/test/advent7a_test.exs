defmodule Advent7aTest do
  use ExUnit.Case
  doctest Advent7a

  # test "parse_line" do
  #   assert Advent7a.parse_line("32T3K 765") == {"32T3K", 765}
  # end

  test "parse_file test.txt" do
    lines = Advent7a.parse_file("data/test.txt")
    assert length(lines) == 5
  end

  # test "sort_hand" do
  #   assert Advent7a.sort_hand("32T3K") == [{1, 2}, {11, 1}, {8, 1}, {0, 1}]
  #   assert Advent7a.sort_hand("T55J5") == [{3, 3}, {9, 1}, {8, 1}]
  #   assert Advent7a.sort_hand("KK677") == [{11, 2}, {5, 2}, {4, 1}]
  # end

  # test "rank_hand" do
  #   assert Advent7a.name_rank("32T3K") == :one_pair
  #   assert Advent7a.name_rank("T55J5") == :three_of_a_kind
  #   assert Advent7a.name_rank("KK677") == :two_pair
  #   assert Advent7a.name_rank("KTJJT") == :two_pair
  #   assert Advent7a.name_rank("KKK77") == :full_house
  #   assert Advent7a.name_rank("KK7KK") == :four_of_a_kind
  #   assert Advent7a.name_rank("AAAAK") == :four_of_a_kind
  #   assert Advent7a.name_rank("AAAAA") == :five_of_a_kind
  #   assert Advent7a.name_rank("AAABB") == :full_house
  #   assert Advent7a.name_rank("12345") == :high_card
  # end

  # test "hand_strength" do
  #   assert Advent7a.hand_strength("22222") == 0
  #   assert Advent7a.hand_strength("22223") == 1
  #   assert Advent7a.hand_strength("222A2") == 12 * 13
  #   assert Advent7a.hand_strength("AAAAA") == 13 ** 5 - 1

  # end

  # test "jokers" do
  #   IO.puts('jokers')
  #   assert "JJ9QK" |> Advent7a.sort_hand()
  #     |> Advent7a.jokers() ==[{11, 3}, {10, 1}, {7, 1}]

  #   assert "T55J5" |> Advent7a.sort_hand()
  #     |> Advent7a.jokers() ==[{3, 4}, {8, 1}]
  #   end
  # test "order hands" do
  #   x = Advent7a.parse_file("data/test.txt")
  #   |> Advent7a.order_hands()
  #   |> IO.inspect()
  #   assert x = 5905
  # end

  test "part two" do
    IO.puts('part two')

    x = Advent7a.parse_file("data/data.txt")
    |> Advent7a.order_hands()
    |> IO.inspect()
    assert x = 6440
  end
end
