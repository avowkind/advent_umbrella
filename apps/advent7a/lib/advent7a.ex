defmodule Advent7a do
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

  @card_rank_j %{
    "A" => 12,
    "K" => 11,
    "Q" => 10,
    "T" => 9,
    "9" => 8,
    "8" => 7,
    "7" => 6,
    "6" => 5,
    "5" => 4,
    "4" => 3,
    "3" => 2,
    "2" => 1,
    "J" => 0,

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

  @doc """

  sort_hand("T55J5") == [{3, 3}, {9, 1}, {8, 1}]
  has a J in it which is a joker.
  scan the hand for the joker value 9. and merge it with the first item
  in the list.
  so we get [{3, 4}, {8, 1}]
  then proceed as normal.
  """
  def jokers([{9,5}]) do
    IO.puts("jackpot!")
    [{9,5}]
  end
  def jokers(hand) do
    # stick jokers on the end
    IO.puts("jokers")
    IO.inspect(hand)
    {list_with_jokers, list_without_jokers} = Enum.split_with(hand, fn {card, _count} -> card == 9 end)
    list_without_jokers ++ list_with_jokers

    # then merge the joker group with the first group
    |> Enum.reduce([], fn x, acc ->
      case x do
      {9, count } ->
        [{hdcard, hdcount} | tail ] = acc
        [{hdcard, hdcount + count}] ++ tail
      _ -> acc ++ [x]
      end
    end)
    |> IO.inspect()

  end
  def rank_hand (hand) do
    hand
    |> sort_hand()
    |> jokers()
    |> Enum.map(fn {_, v} -> v end) # take the counts
    |> Enum.sort(fn x, y -> x > y end) # sort the counts highest first
    |> Enum.take(2) # take the top 2 counts
    |> Enum.chunk_every(2) # group the counts into pairs
    # multiply first count by 10 and add second count
    |> Enum.reduce(0,
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
    |> Enum.map(fn x -> @card_rank_j[x] end)
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
