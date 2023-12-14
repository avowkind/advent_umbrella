# Advent14 - Day 14: Parabolic Reflector Dish

Given input

O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....

We generate
OOOO.#.O.. 10
OO..#....#  9
OO..O##..O  8
O..#.OO...  7
........#.  6
..#....#.#  5
..O..#.O.O  4
..O.......  3
#....###..  2
#....#....  1

Then score the rocks by position.

first we want to read the table and transpose so that we can operate on one row at a time.

Then slide each rock to the left until it hits the head or a #
then score them and sum the rows.

My first version split into shorter arrays broken by the 2 then count the number of 1s in each group and generate the sum.
  e.g. 
  [0,1,0,2, 0, 1,2,0,0,0]
  [0,1,0], [0,1], [0,0,0]
  10 9 8  7 6 5  4 3 2 1

Later version works for the whole list and just counts ones and zeros until we hit a 2 or the end of the list and then fill in that many 1s followed by 0s,

Scoring the array involves Enum.with_index which pairs the elements with their index, this takes a function so we can adjust the index to be length - index giving us a value to multiply either 1 or 0 by and then sum. The scanner just needs to ignore 2s. 

We need to be able to rotate the list by 90deg, The instructions say we lean the list to the N W S E but we want the lean to be on the left so we slide the numbers to the beginning of the array.  Hence the rotation is actually clockwise.  

We don't have (know of yet) a matrix rotation but group theory tells me we can get a rotation from a flip and mirror move i.e transpose and reverse. We just have to do these in the right order to get clockwise or anticlockwise rotations. 
```Elixir
def rotate90(matrix) do
  matrix
  |> Enum.reverse()
  |> List.zip() # Transpose the matrix
  |> Enum.map(&Tuple.to_list/1) # Convert each row to a list
end
def rotate90_left(matrix) do
  matrix
  |> Enum.map(&Enum.reverse/1) # Reverse each row
  |> List.zip() # Transpose the matrix
  |> Enum.map(&Tuple.to_list/1) # Convert each row to a list
end
```
Previous days I used a handwritten transpose but I discovered today that Enum.Zip _is_ a transpose.  Of course it is - didn't realise. 

On feature of the challenge is that under time constraint you don't always have time to go around looking for the best solution.

This gives us all the bits necesary for part1.

## Part 2. 

For part 2 I realised that the numeric optimisation I used in part 1 - that is avoiding doing actual slides by just calculating the count of 1s in each block did not help me here and I would actually need to move the rocks around.  Hence the rewrite of slide_left/1

Having done that we can rotate and slide the rocks as many times as we want. 

This being part 2 however they want ONE BILLION SLIDES. which by brute force would need about 7 hours, less with some optimisations but clearly there is meant to be an optimisation. 

Most likely is that the pattern of movements settles into a repeating cycle - we just need to find out where the cycle starts and its length and we can then skip these from the billion tries and jump to the remainder.

To find the pattern we need to track when we have reached the same position as before after a cycle of 4 turns.  We could just store and compare the previous grids but this seems expensive so we need a number or short string that uniquely represents the grid.  i.e a Hash function. 

The off the shelf hash SHA256 is intended to be crypographically secure etc etc - overkill we just want a number that is unlikely to be duplicated.  After brief research I went for FNV-1a as the result is an integer and fast.  

```elixir
  @doc """
  hash the grid
  we want to compress the grid into a single number that we can use
  to compare with other grids and thus detect cycles.
  We use the FNV-1a hash algorithm to get a single value.
  it does not need to be secure and is fast.

  Example:
          iex> Advent14.hash([[1,2],[3,4],[5,6]])
          3895835992
  """

  @offset_basis 2166136261
  @prime 16777619

  def hash(list) do
    list |> List.flatten() |> Enum.reduce(@offset_basis, &hash_byte/2)
  end

  defp hash_byte(byte, hash) do
    (hash * @prime) |> rem(2**32) |> Bitwise.bxor(byte)
  end
```

So now we can run the cycler for long enough to show up a cycle - I guessed at 100. then review the hash stream for the repeating pattern giving us the start and length of the cycle.

```elixir
@spec find_cycle(Stream.t()) :: {integer, integer}
def find_cycle(stream) do
  Enum.reduce_while(stream, {0, %{}}, fn number, {position, map} ->
    if Map.has_key?(map, number) do
      {:halt, {map[number], position - map[number]}}
    else
      {:cont, {position + 1, Map.put(map, number, position)}}
    end
  end)
end
```

Final solution in 0.5 secs. 


## Learnings

1 - Enum.zip() is a transpose, obvious once you think about it.
2 - then()  a useful operation to maintain the flow of a pipeline. 


## Questions

I'm curious whether, given that we have a chain of immutable functions that Elixir or BEAM is performing all the operations in sequence or is able to optimise all the steps down into one minimalist flow of work. 

How would I even know?  Does adding side effects like print statements mess with the flow?  Is this really faster than mutable arrays?

