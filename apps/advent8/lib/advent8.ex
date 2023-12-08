defmodule Advent8 do
  @moduledoc """
  Documentation for `Advent8`.
  """

@doc """
convert line string "AAA = (BBB, CCC)"
into { :AAA, { :BBB, :CCC } }

  Example:

        iex> Advent8.parse_line("AAA = (BBB, CCC)")
        {"AAA", {"BBB", "CCC"}}
"""
def parse_line(line) do
  case Regex.scan(~r/(\w+) = \((\w+), (\w+)\)/, line, capture: :all_but_first) do
    [[ key, left,right ]] -> { key, { left, right }}
    _ -> { :error, "parse_line failed" }
  end
end

@doc """
read the given file, parse the first line into a rule and the rest into a map of tuples indexed by the first column
"""
def parse_lines(filename) do
  [ hd | tl ] = File.stream!(filename)
    |> Enum.map(&String.trim(&1))

  # grab the rule and split into atoms
  rule = String.graphemes(hd) |> Enum.map(&String.to_atom/1)
  # read the rest of the file in a map { key, { lvalue, rvalue} }
  # hardcoded drop of 2nd line.
  list = tl(tl) |> Enum.map(&parse_line/1)
  { rule, Map.new(list)}
end

@doc """
given a :L or :R and a map of rules
return the next step

Example:

      iex> Advent8.follow_rule("AAA", :L, %{"AAA" => {"BBB", "CCC"}})
      "BBB"

      iex> Advent8.follow_rule("AAA", :R, %{"AAA" => {"BBB", "CCC"}})
"""
defp follow_rule(x, :L, map) do
  {next, _} = map[x]
  next
end

defp follow_rule(x, :R, map) do
  {_, next} = map[x]
  next
end

@doc """
Follow the rules starting at AAA until we get to ZZZ

"""
def follow( {rule, map} ) do

  # make the rule into a cyclic stream generator so we don't run out
  # of rules
  rule_stream = Stream.cycle(rule)
  # start with the first rule
  { _, score } = Enum.reduce_while(rule_stream, { "AAA", 0 },
    fn turn, { step, count } ->
      if step == "ZZZ" do
        {:halt, { step, count }}
      else
        next = follow_rule(step, turn, map)
        {:cont, { next, count+1 }}
      end
    end)
    score
end

@doc """
As for follow but instead of stopping at ZZZ, stop at any Z
Also start at each of the starting points ending in A and return a list of their scores
"""
def follow_to_z({rule, map}) do
  starts = ends_in(map, "A")
  zedset = MapSet.new(ends_in(map, "Z"))
  rule_stream = Stream.cycle(rule)
  Enum.map(starts,
  fn start ->
    Enum.reduce_while(rule_stream, {start, 0},
      fn turn, {step, count} ->
        if MapSet.member?(zedset, step) do
          {:halt, {step, count}}
        else
          next = follow_rule(step, turn, map)
          {:cont, {next, count + 1}}
        end
      end)
  end)

    # nexts = Enum.map(step, &follow_rule(&1, turn, map))
    # {:cont, {nexts, count + 1}}
end
### Part 2

@doc """
return a list of all the keys that end in the given letter

Example:

        iex> Advent8.ends_in(%{"AAA" => {"BBB", "CCC"}}, "A")
        ["AAA"]

        iex> Advent8.ends_in(%{"AAZ" => {"BBB", "CCC"}, "BBZ" => {"DDD", "EEE"}}, "Z")
        ["AAZ", "BBZ"]
"""
def ends_in(map, letter) do
  map |> Map.keys() |> Enum.filter(fn x -> String.ends_with?(x, letter) end)
end


@doc """
Follow the rules starting at xxA until we get to xxZ
This is the slow brute force method. It works for the test data but is too slow for the real data.
"""
def follow2({rule, map}) do
  starts = ends_in(map,"A")
  rule_stream = Stream.cycle(rule)

  {_, score} = Enum.reduce_while(rule_stream, {starts, 0}, fn turn, {step, count} ->
    if rem(count, 10_000_000) == 0, do: IO.inspect({step, count})

    if Enum.all?(step, &String.ends_with?(&1, "Z")), do: {:halt, {step, count}}

    nexts = Enum.map(step, &follow_rule(&1, turn, map))
    {:cont, {nexts, count + 1}}
  end)

  score
end

end

"""
Notes:

# answer is greater than 100_000_000_000
# doing about 10_000_000 per 3 seconds
#  20_000_000 per minute

# 10000000000 / 10_000_000 = 10000 * 3 = 30_000 seconds
# 30_000 / 60 = 500 minutes = 8 hours


we need a serious speed up. if the count is greater than 10_000_000_000
we need to find a way to skip ahead. the
path of each A -> Z must end in a cycle. if it returns to A it will then return to Z again in the same number of step

once we have the cycle time for all 6 paths then they will align at the
greatest common factor (I think)

How to count the cycles.
for each path, count the number of steps until it returns to A
then count the number of steps until it returns to Z

see if it return to the same A or one of the others.

However the LR directions are cycling at a different rate.
there are 307 directions.  - this is a prime.

If all the paths are primes that will be interesting.

So calc the path for each to the first Z

First we need some confidence that the path will eventually reach Z
or if not then an A.

Starts with A.
["HLA", "BXA", "HMA", "AAA", "VTA", "KBA"]
Ends in Z
["KMZ", "XQZ", "KRZ", "ZZZ", "CHZ", "LSZ"]

AAA->ZZZ = 18113 / 307 = 59.
HLA = 20569 / 307 = 67 {"LSZ", 20569}

finding all the paths we get
[
  {"LSZ", 20569},
  {"XQZ", 13201},
  {"CHZ", 16271},
  {"ZZZ", 18113},
  {"KRZ", 18727},
  {"KMZ", 22411}
]

which are all multiples of 307 the number of directions.
[67.0, 43.0, 53.0, 59.0, 61.0, 73.0]

something to do with least common multiple

"""
