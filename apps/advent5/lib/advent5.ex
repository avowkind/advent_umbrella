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
  |> Enum.map(&IO.puts(&1))
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

def check_one([dest, source, range], seed ) do
  if seed in source..(source+range-1) do
    seed - source + dest
  else
    seed
  end
end

def check_seed(seed, lookup) do
  IO.puts("check_seed #{seed}")
  Enum.reduce_while(lookup, seed, fn dsr, acc ->
    result = check_one(dsr, acc)
    if result != acc do
      {:halt, result}
    else
      {:cont, acc}
    end
  end)
end

def check_seed_layer(seed, layer, tables) do
  IO.puts("check_seed #{seed}")
  lookup = tables[layer]
  check_seed(seed, lookup)
end

@layers [:tosoil, :tofertilizer, :towater, :tolight, :totemp, :tohumid, :toloc]
def all_layers(seed, tables) do
  @layers
  |> Enum.reduce(seed,
    fn layer, acc ->
      IO.puts("acc #{acc} layer #{layer}")
      check_seed_layer(acc, layer, tables)
  end)
end

def do_seeds(table) do
  seeds = table[:seeds]
  Enum.map(seeds, fn seed ->
    all_layers(seed, table)
  end) |> Enum.min()
end

def part1() do
  lines = parse_file( )
  table = parse_input(lines)
  do_seeds(table)
end

end
