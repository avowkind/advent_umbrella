# Advent16  Day 16: The Floor Will Be Lava

## Parsing file

The file format is yet another square grid of characters. This time .|-\/ that represent mirrors that change the direction of the light beams.

Looking at the main data.txt we see a grid of 110x110 which suggests that the ray paths we want to follow will require a large number of iterations.  We also know that splits will require tracking a tree of paths through the system - to complete in reasonable time we need these steps to be fast:

- position to character value
- {move} to next move 

We want to be able to quickly look up the character at a location and knowing that arrays or matrices have linear lookup time I decided to create a map of each position and character.  

There is a choice between representing the position as {x,y} or an absolute index (pos) 
{x,y} makes moving up,down,left,right simple addition and simple detection of off the map, while pos requires up/down moves to add the row length but gives us a single value key for the map.  I chose the latter. 

To get this we join all the rows into one string, remove the returns, split into graphemes, the enum with_index, making the index the first value in the tuple then Enum.into(%{}) creates the map. 



## Move rules

We need to encode the rules for how a ray moves from one cell to another.  At each step the new cell depends on the mirror in the cell and the direction of travel so our basic unit of tracking is the move tuple { dir, pos }

The `apply_rule( move, ch)` function takes the position and a character and returns the next move. If we go off the map then return an {:out, x} tuple so that we can terminate the ray.

For part 1 I expressed this as another map based on the character which returns a function that gives the new position based on the character.  We return an array which usually has one element, but when we hit a split we return both new moves. 

The map needs to know the width of the grid so that it can apply row changes. Even if we used {x,y} positioning we would need to know the off map lengths. 

This results in the map being dynamically generated in the apply_rule function.  I presume this was cached but the whole thing was not very fast. I needed lots of tests to confirm that each mirror worked as intended. when you have a lot of very similar lines like `[{ :left, pos - 1}]` `[{:down, pos + @row}]` it is easy to get one wrong.

The off map detection was made more complex by the use of pos instead of x,y, as I had to check the direction of travel as well as the value. 

## Ray Tracing

Without splits the ray tracing algorithm is simple, start at the start position {:right, 0}, get the next move and call the ray tracer again with the new position, keeping track of the list of previous positions as we go. If the move is {:out} then stop and return the accumulator.  There is no feed to be processed so no reducer, instead we just call ray_trace repeatedly. 

With splits its a little more complex - but not too much, just call ray_trace on the first direction, followed by ray_trace on the second direction.  

My first attempt at this just used Enum.map on the array of moves. passing the accumulator in to each sub call.  This had problem though...

## Detecting cycles

Not all rays exit via the edge of the map. Some end up in a cycle of mirrors inside the map and we need to detect this and {:out} at that point.  As the accumulator passed into ray_trace holds the list of previous moves we can just check if we have been here before ( for both direction and position).  However, with my first algorithm while a cycle in one sub path would eventually return to the same position, any other path falling into the same cycle would have to find this out for itself. 

The fix is to not run both paths separately with the same acc, but to run one - the left, and then pass the result into the right. This is a massive speed up. 

Another type of cycle to notice is that hitting a splitter from either side results in the same two outputs. Detecting this repeat from another direction saves us calculating both sub branches of the tree. 


## Pattern matching

The first draft of the ray_tracer was very messy with nested if elses and cases checking for bits and pieces. 
I was able to tidy it it up by:

- remove the :out case to a separate function
- destructure and pattern match at the same time
e.g
```elixir
case apply_rule(move, Map.get(map, pos)) do
        [move] -> ray_trace(acc, move, map)
        [move1, move2] ->
```

instead of 
```elixir
if length(moves) == 2 do
  a
else
  b
```

## Rule optimisation

The map of functions rules processor was still too slow. I could do one of two things:

- use the map to generate a lookup table map of the form 
```elixir
%{
  {dir,pos} => [ {:up, upos}, {:down, dpos}, {left: lpos}, {right: rpos}]
}
```

- or hard code the rules with guards
```elixir
def rule({dir, pos}, ch) when dir == :up and ch in [".", "|"], do: [{:up, pos - @row}]
  
def rule({dir, pos}, ch) when dir == :down and ch in [".", "|"], do: [{:down, pos + @row}]
```

I went with hard coding the rules, which is very readable and I was able to merge several of the rules together.  The downside of this is that the width of the input is also hard coded into @row 110.   This means I have to change it for testing on smaller tables. 

## Final Result

These optimisations brought the run time for a single trace to 0.3 seconds. Close enough to do the four sides * 110 entry points. About 89 seconds. 

*Bonus*: Tasks and concurrency

This final version (done the next day). Makes use of the fact that each ray trace is independent and can thus be run concurrently.  This is trivial in Elixir:

```elixir

  def run3(file_path) do
    map = parse_file(file_path)
    tasks = for dir <- [:left, :right, :up, :down], i <- 0..109 do
      Task.async(fn ->
        Advent16.ray_trace([], {dir, i}, map)
        |> Advent16.count_pos()
      end)
    end

    tasks
    |> Enum.map(&Task.await(&1, 10000))
    |> Enum.max()
  end
```

Final time < 10 seconds


## Learnings

Note - most of these come after the result when reviewing the code for better versions.

- use `value in collection` test not Enum.member? 
- use `for dir <- [:left, :right, :up, :down], i <- 0..109` this gives us a matrix iteration for '{dir,i}'
- don't be slow to use concurrency
- if else statements are code smell here and may often be replaced with either pattern matched functions with guards or case matches.  However some guards are not allowed - I couldn't do `def ray_trace(acc, move) when move in acc, do: acc` for example as acc was too dynamic to make a precompiled function for. 



