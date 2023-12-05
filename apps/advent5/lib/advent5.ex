defmodule Advent5 do
  @moduledoc """
  Documentation for `Advent5`.

"""
@sample_data """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""


def parse_strings() do
  @sample_data
  |> String.split("\n")
end

def parse_file() do
  File.stream!("data/data.txt")
  # |> Enum.map(&IO.puts(&1))
end
def line_to_integers(line) do
  String.split(String.trim(line), " ", trim: true)
  |> Enum.map(&String.to_integer/1)
end
def parse_map_line(line, acc) do
  [key | rest_of_line] = String.split(line, ":")
  key = String.trim(key)
  case key do
    "seeds" ->
      seeds = line_to_integers(hd(rest_of_line))
      Map.put(acc, :seeds, seeds)
    "seed-to-soil map" ->
      Map.put(Map.put(acc, :current, :tosoil), :tosoil, [])
    "soil-to-fertilizer map" ->
      Map.put(Map.put(acc, :current, :tofertilizer), :tofertilizer, [])
    "fertilizer-to-water map" ->
      Map.put(Map.put(acc, :current, :towater), :towater, [])
    "water-to-light map" ->
      Map.put(Map.put(acc, :current, :tolight), :tolight, [])
    "light-to-temperature map" ->
      Map.put(Map.put(acc, :current, :totemp), :totemp, [])
    "temperature-to-humidity map" ->
      Map.put(Map.put(acc, :current, :tohumid), :tohumid, [])
    "humidity-to-location map" ->
      Map.put(Map.put(acc, :current, :toloc), :toloc, [])
    _ -> acc
  end
end



def parse_ints(line, acc) do
  key = acc[:current]
  ints = line_to_integers(line)
  if key == nil do
    acc
  else
    Map.put(acc, key, acc[key] ++ [ints] )
  end
end

def parse_input(input) do
  input
  |> Enum.reduce(%{},
    fn line, acc ->
      cond do
        String.contains?(line, ":") ->
          parse_map_line(line, acc)
        String.trim(line) |> String.length() == 0 ->
          acc
        true ->
          parse_ints(line, acc)
      end
    end)
end

# def check_one([dest, source, range], seed ) do
#   if seed in source..(source+range-1) do
#     seed - source + dest
#   else
#     seed
#   end
# end
# version using guards and separate functions
def check_one([dest, source, range], seed ) when seed in source..(source+range-1) do
  seed - source + dest
end

def check_one(_, seed), do: seed

# uses with
def check_seed(seed, layer) do
  Enum.reduce_while(layer, seed, fn dsr, acc ->
    with result <- check_one(dsr, acc),
      true <- result != acc do
        {:halt, result}
    else
      _ -> {:cont, acc}
    end
  end)
end


def all_layers(seed, tables) do

  Enum.reduce([:tosoil, :tofertilizer, :towater, :tolight, :totemp, :tohumid, :toloc], seed,
    fn layer, acc ->
      check_seed(acc, tables[layer])
  end)
end

def do_seeds(seeds, table) do
  Stream.map(seeds, fn seed ->
    # IO.puts("#{seed}")
    all_layers(seed, table)
  end) |> Enum.min()
end

def part1() do
  lines = parse_file( )
  table = parse_input(lines)
  seeds = table[:seeds]
  do_seeds(seeds, table)
end


@doc """

4225564962
127158107
239072070
1254705509
1312864011
374323335
942540950
197937586
70478641
56931769
part2 ok
.
Finished in 1707.6 seconds (0.00s async, 1707.6s sync)
1 test, 0 failures

"""
@speedup 1
def seed_range [start, count], table do
  top = start + count/@speedup
  Stream.unfold(start, fn i -> if i < top, do: {i, i + 1}, else: nil end)
  # |> Stream.map(fn seed ->
  #   Enum.reduce([:tosoil, :tofertilizer, :towater, :tolight, :totemp, :tohumid, :toloc], seed,
  #     fn layer, acc ->
  #       check_seed(acc, tables[layer])
  #     end)
  # end)
  # |> Enum.min()
  |> Enum.reduce({nil, nil}, fn seed, {min_value, min_seed} ->
    value = Enum.reduce([:tosoil, :tofertilizer, :towater, :tolight, :totemp, :tohumid, :toloc], seed,
      fn layer, acc ->
        check_seed(acc, table[layer])
      end)

    if min_value == nil or value < min_value do
      {value, seed}
    else
      {min_value, min_seed}
    end
  end)
  |> elem(0)
end

def part2() do
  table = File.stream!("data/data.txt") |> parse_input()
  seeds = table[:seeds]

  Stream.chunk_every(seeds, 2)
  |> Task.async_stream(&seed_range(&1, table), timeout: :infinity)
  |> Enum.to_list()
  |> Enum.filter(fn {status, _} -> status == :ok end)
  |> Enum.map(fn {_, result} -> result end)
  |> Enum.min()
  |> IO.inspect()

end



def counttrys() do
  seeds = [2906961955, 52237479, 1600322402, 372221628, 2347782594, 164705568, 541904540, 89745770, 126821306, 192539923, 3411274151, 496169308, 919015581, 8667739, 654599767, 160781040, 3945616935, 85197451, 999146581, 344584779]
  Enum.chunk_every(seeds, 2)
  |> Enum.reduce(0, fn [start, count], acc ->
    IO.puts("start #{start} count #{count}")
    acc + count
  end)
end
end
