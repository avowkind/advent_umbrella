# Advent13 Day 13: Point of Incidence

#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#

Finding reflections in pairs of maps

We solve for rows, then we can transpose the matrix for cols.

start by finding find two rows with the same pattern. 
Then verify that prev and next rows match until the end.
if fails continue scanning for the next row.

return the row number of the first of the matched pair.

We can quickly compare the rows by either scanning the chars arrays, which we would have to do repeatedly, or perhaps converting to binary and comparing number. We are good up to about 64 bits. So I decided to convert . to 0 and # to 1 then compress into a single number array e.g [102, 90, 385, 385, 90, 102, 346]
This paid off later

Its possible for there to be no matches in the rows or columns but this would give us a score of 0 which would be correct. 

Its possible for there to be multiple line pairs that match but for only one of which is a true reflection to the edge of the map.  So we start by finding all the mirror candidates and then check their reflections. if both are reflected to the edge we want the longest one. This will be the one closest to the centre. 

We can check for reflections by splitting the array at the candidate point reversing one of the arrays, zipping into a pairwise set and then checking for all the pairs matching. 

The rest is housekeeping. 

## Part 2

One symbol in the map can be changed to generate alternative reflections. 
We are already finding the nearly matched centres we just need to change the comparison function to allow for one of the matches in the set to be out by one bit. 
I have to admit that I had GPT lookup the logic for one bit different: ( a xor b) and ((a xor b) -1).

Found the Bitwise module useful here.

This was the first time part 2 took less time than part 1. Thanks to having the data structures all in a useful form.

## Learnings

*split_at_empty* - this is was a hacky way to split all the maps in the file into an array of maps. It would have been better to do this at the line parsing stage by reducing the lines directly into the arrays - but I was interested in how it would be done. Good to discover yet another Enum function. I guess there are so many as they form the essentials for replacing for and while loops in this immutable word.  Under the hood they are all forms of map/reduce which in turn is recursion but they protect the mind from the horrors. 

*single_bit_difference* - I just like this. 
```elixir
  def single_bit_difference?(a, b) do
    Bitwise.band((Bitwise.bxor(a,b)),(Bitwise.bxor(a,b) - 1)) == 0
  end
```

There are operators for these functions ^^^ but here the names are a lot clearer.  

*lots of small functions* - you can of course use lots of lambdas and nest calls directly into the maps - the whole app could be a single function. But this would be very very hard to understand. 

I get the feeling that function calls are cheap here anyway so little overhead from making each map or reduce lambda into a separate function.  The time to not do this is when we want to bake in some variable from the outer clauses. We can avoid passing in the value to a function call by either using the lambda directly or using nested functions as closures. 

This problem ran so fast we didn't need any optimisation so readability comes first. 

*libraries* - I don't know all the libraries yet so I am probably writing functions (like transpose) that exist in better forms somewhere. Its a trade off between searching the manual for packages or just writing something. 






