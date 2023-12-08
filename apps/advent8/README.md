# Advent8 - Haunted Wasteland

<https://adventofcode.com/2023/day/8>

So this was fun. Solved with a single major function.

As before we start with a parser.  I've taken to putting both the test data and real data in text files so that they are read in by the same route instead of putting the test data in the tests.  

Also started using doc tests for the simpler functions. 

The follow_rule function takes the :L or :R direction and returns the next position from a map entry.  My first pass at this used an if/else, 2nd time a case and third time two co-functions or whatever these functions with the pattern matched signature are called. (function-clauses apparently.)

```elixir
@doc """
given a :L or :R and a map of rules
return the next step
"""
defp follow_rule(x, :L, map) do
  {next, _} = map[x]
  next
end

defp follow_rule(x, :R, map) do
  {_, next} = map[x]
  next
end
```

These are the centre of the mapping loop so it helps if they are efficient. Although as it turns out that's not important

The part 1 follow function takes the map and rules and starting at AAA follows the track until we get to ZZZ.

A really nice function here is `Stream.cycle(rule)` which provides me with a continuously repeating input of the L R tokens that I can feed into a reducer. 

We use `Enum.reduce_while/3` to allow us to consume the feed turning L and R through the map until we return an accumulator tuple with :halt. otherwise we return :cont for continue. 

While we are reducing we just increment a counter in the accumulator for each step until the test fails. 

Piping the data.txt stream into follow gives us the part 1 result.

## Part 2. 

The description of part two had me thinking that it couldn't be as simple as tracing all 6 paths until they lined up like a slot machine scoring 6 cherries.  I ran a version for a few minutes to get an idea of the number of iterations I could do in a minute ( about 30 million)

I checked by putting in a largish guess answer to the AoC site and got 'that number is too low' so I knew we needed at least 11 digits - which meant brute force was out.

Had to go walk the dogs and have a think...

Fortunately I had noticed the length of the turns rule (307) and it was suspiciously prime. 

A check showed the first answer was a multiple of 307 and another prime (67) and so we are on to a classic problem in number theory.

It makes sense really this type of problem would not work very well unless the cycles are effectively co-prime to each other. 

So the hypothesis is that each starting point ends on a different Z and returns back to its own A, i.e the paths don't cross, loop or otherwise get knotted. otherwise it would be hard to create a problem known to terminate in finite time.

A modification to the follow function `follow_to_z` generated the list of path lengths. 
```
[
  {"LSZ", 20569},
  {"XQZ", 13201},
  {"CHZ", 16271},
  {"ZZZ", 18113},
  {"KRZ", 18727},
  {"KMZ", 22411}
]
```
Which yes are all primes multiplied by 307.  

The latter ensures that each path reaches its Z at the end of the rule cycle.  Hence the answer would be the least common multiple of all the number pairs.   I'll admit I had to look up exactly which of LCM, GCF LCF and other math bits was the one I wanted.

I think I should have also checked that having reached Z the path takes its way back to A in a similarly consistent fashion.  But I bunged in the answer just in case and it was correct. So Stop.

### Learnings

MapSet is Elixirs main class for managing sets. It can handle lookups in log time. So I used it to check whether the current position matched one of the end positions.

```elixir
zedset = MapSet.new(ends_in(map, "Z"))
...
if MapSet.member?(zedset, step) do
```

This probably is not quicker than checking if the string ends in Z though.

Once again I think Elixir expresses the solution to these parsing and pattern matching problems really cleanly.

