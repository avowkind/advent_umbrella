# Advent5 --- Day 5: If You Give A Seed A Fertilizer ---


This one took some thought.
It was not to hard to write the parser and once having constructed the tables the calculation was a fairly terse reduce.

Part 2 looked trivial - just an expansion of the seed array - one line.... And an explosion that had me calculate a 13 hour run.
After some sleep I optimised it down to 1102 seconds. - 

- remove all IO statements,
- use Streams (lazy evaluation) to prevent memory overflow
- use async_stream to spread the 10 seed expansions over my mighty M2 cores. 
- collapse a reduce,reduce, min into a single reduce. 

All the above made very simple in Elixir. 

Here is that very nice splitting into async tasks:

```elixir
  table = File.stream!("data/data.txt") |> parse_input()
  seeds = table[:seeds]

  Stream.chunk_every(seeds, 2)  # break the seeds into groups of start and range.
  |> Task.async_stream(&seed_range(&1, table), timeout: :infinity)  # run the 10 groups in parallel
  |> Enum.to_list() # collate the results.
  |> Enum.filter(fn {status, _} -> status == :ok end) # filter out the successes  - although none fail.
  |> Enum.map(fn {_, result} -> result end) # take the min of the results
  |> Enum.min()
```

Other people have less than 5 minutes algorithms that either work backwards through the tables or avoid having to do all the seeds by calculating the overlapping ranges. 

I think one might reduce each layer onto its previous one splitting ranges where they overlap until you have a single layer with more ranges in it. This is probably where you get a significant speed up. 
But I think that would have taken more than 30 minutes.


