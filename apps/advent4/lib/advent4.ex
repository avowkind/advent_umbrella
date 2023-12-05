defmodule Advent4 do
  @moduledoc """
  Documentation for `Advent4`.
  """

  @doc """
  read Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  into {[41, 48, 83, 86, 17], [83, 86, 6, 31, 17, 9, 48, 53]},
  """
  def parse_card(card) when card == "", do: nil
  def parse_card(card) do
    [card_number, card_values] = String.split(card, ":")
    "Card " <> card_number = String.trim(card_number)
    card_id = String.to_integer(String.trim(card_number))
    [winners, card_values] = String.split(String.trim(card_values), "|")
    winners = String.split(String.trim(winners), " ", trim: true) |> Enum.map(&String.to_integer/1)
    values = String.split(String.trim(card_values), " ", trim: true) |> Enum.map(&String.to_integer/1)
    # IO.inspect(values)

    {card_id, score_card(winners, values)}
  end

  def score_card(winners, values) do
    values |> Enum.filter(fn value -> Enum.member?(winners, value) end) |> Enum.count()
  end

#   def check_score({winners, values}) do
#     matches = values |> Enum.filter(fn value -> Enum.member?(winners, value) end) |> Enum.count()
#     matches |> check_score()
#     case matches do
#       0 -> 0
#       n -> 2 ** (n-1)
#     end
#  end


  def parse_cards(scratch_cards) do
    scratch_cards
    |> String.split("\n")
    |> Enum.map(&parse_card/1)
    |> Enum.sum()
  end

  # def run_file() do
  #   File.stream!("data/data.txt")
  #     |> Enum.map(&parse_card/1)
  #     |> Enum.sum()
  # end

# """
# 123456
# 1,4
# 2345 2345 6 , 1

# 2,2
# 1 2 34 34 5 2 34 34 5 6
# 3,2
# 1 2 3454 3454 5 2 3454 3454 5 6
# 4,1
# 1 2 345545 345545 5 2 345545 345545 5 6
# """
  def duplicate_list_n_times(list, n) do
    Enum.flat_map(list, fn x -> List.duplicate(x, n) end)
  end

  def expand_card_list(card_list) do
    IO.puts("ecl/2")
    card_list
    |>  Enum.reduce(card_list,
      fn  card, acc ->
        { id, score } = card
        copies = Enum.take(Enum.drop(acc, id), score)
        IO.puts("id: #{id} score #{score} len #{length(acc)}")
        # IO.inspect(acc)
        # IO.inspect(copies)
        # go through the accumulator following all id with a copies
        # count the number of id matches in the accumulator
        count = Enum.count(acc, fn {id2, _} -> id == id2 end)
        IO.puts("count of #{id} is #{count}")
        # add that number of copies to the end
        acc ++ Enum.flat_map(copies, fn x -> List.duplicate(x, count) end)
      end)
  end

  # part 2
  def expand_cards(scratch_cards) do
    scratch_cards
    |> String.split("\n")
    |> Enum.map(&parse_card/1)
    |> expand_card_list()
    |> IO.inspect()
    |> length()
  end

  def run_file2() do
    File.stream!("data/data.txt")
      |> Enum.map(&parse_card/1)
      # |> IO.inspect()
      |> expand_card_list()
      |> length()
  end
end
