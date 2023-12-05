defmodule Advent4Test do
  use ExUnit.Case
  doctest Advent4
@scratch_cards String.trim_trailing("""
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
""")


test "check_score" do
#   card = {[41, 48, 83, 86, 17], [83, 86, 6, 31, 17, 9, 48, 53]}
  card = "Card   1: 44 22 11 15 37 50  3 90 60 34 | 35 60 76  3 21 84 45 52 15 72 13 31 90  6 37 44 34 53 68 22 50 38 67 11 55"
  assert Advent4.parse_card(card) == {1, 10}
end

# test "parse_cards" do
#   assert Advent4.parse_cards(@scratch_cards) == 13
# end

test "list dup" do
  assert Advent4.duplicate_list_n_times([1,2,3], 1) == [1,2,3]
  assert Advent4.duplicate_list_n_times([1,2,3], 3) == [1, 1, 1, 2, 2, 2, 3, 3, 3]
end
# test "run file" do
#   assert Advent4.run_file() == 21105
# end

test "expand_cards" do
  assert Advent4.expand_cards(@scratch_cards) == 30
end
@tag timeout: :infinity
test "run file2" do
  assert Advent4.run_file2() == 21105
end
end
