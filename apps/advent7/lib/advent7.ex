defmodule Advent7 do
  @moduledoc """
  Documentation for `Advent7`.
  """


  def data_file() do
  end
  def test_file() do
    File.stream!("data/test.txt")
  end

  def parse_line(line) do
    [hand | bid] = String.split(line, " ", trim: true)
    hand = String.trim(hand)
    bid = String.to_integer(String.trim(hd(bid)))
    { hand, bid }
    # |> IO.inspect()
  end

  def parse_file(filename) do
    File.stream!(filename)
    |> Enum.map(&parse_line/1)
    # |> IO.inspect()

  end


  @doc """
    :5_of_a_kind,  Five of a kind, where all five cards have the same label: AAAAA
    :4_of_a_kind,  Four of a kind, where four cards have the same label and one card has a different label: AA8AA
    :full_house,  Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
    :3_of_a_kind,  Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
    :2_pair,  Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
    :1_pair,  One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
    :high_card  High card, where all cards' labels are distinct: 23456
  """
  # @hand_types [
  #   :five_of_a_kind,
  #   :four_of_a_kind,
  #   :full_house,
  #   :three_of_a_kind,
  #   :two_pair,
  #   :one_pair,
  #   :high_card
  # ]

  @card_rank %{
    "A" => 12,
    "K" => 11,
    "Q" => 10,
    "J" => 9,
    "T" => 8,
    "9" => 7,
    "8" => 6,
    "7" => 5,
    "6" => 4,
    "5" => 3,
    "4" => 2,
    "3" => 1,
    "2" => 0,
  }

  @base 13
  @doc """
  Sorts a hand of cards into a list of tuples
  of the form {card_rank, count}
  ordered by the count of each card rank
  """
  def sort_hand(hand) do
    hand
      |> String.codepoints()
      |> Enum.map(fn x -> { @card_rank[x], 1 } end)
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.map(fn {k, v} -> {k, length(v)} end)
      |> Enum.sort(fn {_, v1}, {_, v2} -> v1 > v2 end)
  end

  def hand_rank do %{
    5 * @base => :five_of_a_kind,
    4 * @base + 1 => :four_of_a_kind,
    3 * @base + 2 => :full_house,
    3 * @base + 1 => :three_of_a_kind,
    2 * @base + 2 => :two_pair,
    2 * @base + 1 => :one_pair,
    1 * @base + 1 => :high_card,
  }
  end

  def get_hand_rank(code) do
    hand_rank()[code]
  end

  def rank_hand (hand) do
    hand
    |> sort_hand()
    |> Enum.map(fn {_, v} -> v end) # take the counts
    |> Enum.sort(fn x, y -> x > y end) # sort the counts highest first
    |> Enum.take(2) # take the top 2 counts
    |> Enum.chunk_every(2) # group the counts into pairs
    |> Enum.reduce(0, # multiply first count by base and add second count
      fn (x, _acc) ->
        case x do
          [a,b] -> a * @base + b
          [a] -> a * @base
        end
      end)
  end

  def name_rank(hand) do
    hand |> rank_hand() |> get_hand_rank()
  end

  @doc """
  converts each hand card into a numerical value and
  generates an integer by multiplying the card value by its
  position in the hand base @base as there are @base cards.
  """
  def hand_strength (hand) do
    hand
    |> String.codepoints()
    |> Enum.map(fn x -> @card_rank[x] end)
    |> Enum.with_index()
    |> Enum.map(fn {x, i} -> x * (@base ** (4 - i)) end)
    |> Enum.sum()
  end

  def score_hand(hand) do
    rank_hand(hand) * (13 ** 5) + hand_strength(hand)
  end

  def order_hands(hands) do
    num_hands = length(hands)
    hands
    |> Enum.map(fn { hand, bid } -> {hand, score_hand(hand), name_rank(hand), bid} end)
    |> Enum.sort(fn {_, v1, _, _ }, {_, v2, _, _ } -> v1 > v2 end)
    |> Enum.with_index(fn element, index ->
        { _,_,_, bid } = element
        IO.inspect({bid, index})
        { bid * (num_hands-index), element} end)
    |> IO.inspect()

    |> Enum.map(fn {x, _} -> x end)
    |> Enum.sum()
  end
end
