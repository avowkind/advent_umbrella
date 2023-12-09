#  Advent of Code 2023, Day 9 Mirage Maintenance

Task:

- Read a line of numbers, find the differences between each pair of numbers.
- Repeat until all the differences are 0.
- find the next number in the sequence.  Sum the set of next numbers.
- part 2 find the previous number in the sequence.

## Parsing

Trivial parsing - just read the file and split into an array of integers.

I keep the parse_line and parse_file functions separate although they could be merged because its easier to test.

Parsing an array of numbers could be done in 2 ways - using string split, 
or using a regular expression. 

The oddity about Regex.split is that the regex is the first parameter so that piping the line doesn't work so neatly. While the result is one line shorter and avoids an extra trim, compiling the regex is more complex.

```elixir
 def parse_line(line) do
    line
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_line_regex(line) do
    Regex.split(~r/\s+/, line)
    |> Enum.map(&String.to_integer/1)
  end
```

For the file size we are working with this makes little to no difference. 

## Diffs

we need to process each array into a list of its differences.  I wondered whether there was a way to avoid doing the whole centre of the array and just the ends - but we couldn't be sure.  So as usual try it and don't optimise prematurely. 

There's a few ways to run through the differences. I used chunking into pairs, but a single reducer would also do it. 

```elixir
 def diffs(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

```

## recursion

A valid use for a recursive function - we repeat the diffs on the array until all the entries are zero.

```elixir
  def next_in_sequence({list, acc} ) do
    ## get the last item and add it into the accumulator
    acc = acc + List.last(list)

    # calc the diffs
    new_list = diffs(list)
    if Enum.all?(new_list, &(&1 == 0)) do
      acc
    else
      next_in_sequence({new_list, acc})
    end
  end
``` 

The test for the end: `Enum.all?(new_list, &(&1 == 0))`
I thought could be replaced with `Enum.sum(new_list) == 0` its much the same work but doesn't require an intermediate list of truths.  But no - as a line -1,1,-1, 1 also sums to zero.  we must only have real zeros.

## Calc next in sequence

The rest is simple feed the line into the difference engine and work out the next in sequence.  I noticed that we didn't really need to add extra items to each list - the next in sequence is the sum of the last values in each difference list. 


## Part 2

Part 2 calculates the predecessor of the sequence.  This is practically identical to the successor and we already have the data structure available. 

However we can just sum the heads of the lists - we need to negative sum them. However the result is not a - b - c - d.  Its
a - (b - (c - d))  which is not the same

4 - 3 - 2 - 1 = -2
while
4 - (3 - (2-1)) = 2

but it is equvalent to 
(1 * 4) + (-1 * 3) + (1 * 2) + (-1 * 1)

So we can sum the heads of the rows multiplying each by 1 or -1 each time, and we generate the sequence of 1, -1 by multiplying i by -1 each time. 

here is the final version. the little wrapper function ensures the recursive function starts with the correct accumulator. 

```elixir
  def prev_next_in_sequence( list ) do
    { a,b,_} = r_prev_next_in_sequence({list, {0,0,1}})
    { a, b }
  end  
  defp r_prev_next_in_sequence({list, acc} ) do
    { first, last, i } = acc
    acc = { first + i* List.first(list), last + List.last(list), i*-1 }
    new_list = diffs(list)
    if Enum.all?(new_list, &(&1 == 0)) do
      acc
    else
      r_prev_next_in_sequence({new_list, acc})
    end
  end
```

## Learnings

- As always never try to find the best implementation first time around - always go for clarity and works correctly.  After solving I tried various things to make the code look neater, run faster, e.g using the Sum or regex and these usually broke the solution. 

- Functional programming recursion a lot, especially for running down lists, but it can make one's head hurt to think about. Standard functions like `reduce` hide this complexity and you can just pass in the step handler function and accumulator.  However in some cases the explicit recursion is clearer.

Here is the reducer version. Its much the same. 

```elixir
defp r_prev_next_in_sequence({list, acc}) do
  Enum.reduce_while(list, acc, fn _, acc ->
    {first, last, i} = acc
    acc = {first + i * List.first(list), last + List.last(list), i * -1}
    new_list = diffs(list)

    if Enum.all?(new_list, &(&1 == 0)) do
      {:halt, acc}
    else
      {:cont, {new_list, acc}}
    end
  end)
end

```
Really all we have done is use the :halt and :cont flags to terminate a while loop.

I quite liked my use of i * -1 to generate the alternating + and - but there is probably tidier mathematical solution.


## A note on Machine Assistance

I don't use AI/GPT/Codepilot to help me solve the problem, develop the algorithm etc.  I do allow copilot to autocomplete lines, fill in tests etc. 

I also rely a fair bit on the syntax checking and error messages in the editor and test running. 

After completion I also use AI to review the code and suggest improvements.

