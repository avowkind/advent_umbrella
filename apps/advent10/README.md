# Day 10: Pipe Maze ---

For this one I did some paper thinking before starting coding. 

## Algorithm
Given a map like
.....
.S-7.
.|.|.
.L-J.
.....

We need to find the furthest distance from the S along connected pipes.
We will need to scan the map for the starting position

For each of the four possible directions only certain symbols would be valid moves. There are 6 symbols - 2 edges |- and 4 corners FJL7 which represent turns. 

Starting at S - we are told only 2 paths lead out. 

to the west it must be one of: - west  L north  F south 
to the north it must be: | north  F east  7 west
to the east - east  J north  7 south
to the south | south J west  L east

To find the first move Scan the cells to the NESW and see if they are one of the 3 valid symbols:

N = "|F7", E = "-J7", S = "|JL", W = "-FL"

Only two of these directions should be valid. But we only need the first as we can go around the loop in either direction until we reach the start and /2 instead of following both paths. 

To follow a path - the direction we turn depends on how we arrived there - the previous move, so the main walker tuple will be { move, {x,y} }

We will need a functions to take a move and return the next one. Then we can recursively walk the map until we get back to the start. 
  
## Storage format:

Need to store the map as a matrix or a network so that we can move NESW easily.
We want something that we can easily access with row,col (or x,y)

We could use a matrix library, or some collection intended for this purpose. But I just went with the original data - an array of strings. 

Knowing the string length we can create a function to move in any direction by +-1 for the col (x) and +- row length for the row (y)

```elixir
  # handle potentially going off the map
  def move_direction({x, y}, _) when x < 0 or y < 0 do
    nil
  end

  # new coordinate for a move.
  def move_direction({x, y}, dir) do
    case dir do
      :N -> {x, y - 1}
      :E -> {x + 1, y}
      :S -> {x, y + 1}
      :W -> {x - 1, y}
    end
  end
```
I consider using a network. If a network then each cell is given an ID. and a link to the neighbours
e.g (4, { 0, 5, 15, 3, })

building the network takes longer but traversal is immediate. 

lets just keep an array of strings accessed by codepoint

e.g[".S-7.", ".|.|."]
so `char(x,y) = Enum.at(map, y) |> String.at(x)`

This feels inefficient - we could perhaps expand the string into a char array. 

### Putting it all together.

we read in the file, find the start position and first move, take that step and then start following the path until we arrive back at the start. 
```elixir
  def run1(file_path) do
    grid = parse_file(file_path)
    { start, [ move | _ ] }  = start_moves(grid)
    first_step = { move, move_direction(start, move)}
    follow(first_step, grid, 1) / 2
  end
```

## Part 2

We need to identify areas inside the loop these are chars that are not on the path.

We can get the count by marking the path with a value, and somehow marking the inside and outside locations with different values.  i.e. a colour map. 

Marking the path is easy, walk the path replacing each edge with a 1 and each corner with a +,  (later replaced with corner markers )

Finding the inside - I think its something to do with the number of edges you cross getting to the outside.

so here
...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O.....

if we start at a cell we want to find the nearest edge - or perhaps that doesn't matter.
we need to avoid being confused by other bits of pipe
so replace - and | with 1 S7LJ with 2 only on the path. 
find a side that has a 1 and count 1s in that direction. 
inside the loop will be odd, outside even.


Take 2 - shoot rays across the grid start at 0 if hit the path increase marker to 1, if running on path ignore, after path decrease marker to 0 
write the marker in non path slots. 

I went with the shooting rays. starting at x=0 replace each char you find with a 0 until you hit a path, then increment, when off the path if the counter is even replace with a zero if odd replace with a 2.  
( could add/decrement for each crossing but I used rem(d,2) instead )

Testing with the helpful data examples I found that while the basic idea worked it broke down if the ray traversed along an edge i.e from +----+ .  To fix this I needed to track whether the edge acted as a crossing or not. To do this we need to mark the direction of the first corner F or L as :top or :bottom. and then compare with the second corner so that :top + J is a line crossing while :top + 7 is not. 

In order to avoid being confused by other bits of pipe we replace all the corner markers with their value +1.  J -> K.  This is not very nmemonic and I could have just replaced each character with a tuple { ch, type } but this was not necessary. 