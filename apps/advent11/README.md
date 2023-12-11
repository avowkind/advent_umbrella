# Day 11: Cosmic Expansion

This challenge presents us with another 2D Map, this time of galaxies. Yesterday after struggling with 2D representations in an immutable world I read a couple of articles and realised the value of keeping state in a list of the objects of interest rather than the board itself.  

## Basic algorithm

Read the lines into arrays of integer arrays replacing the "#" and "." chars with 1 and 0.  Probably we could work directly with the symbols but definitely easier to expand the line strings into arrays of codepoints.

Scan the grid into a list of the coordinates of the galaxies. As we are going to compare them all we don't really need to number them as suggested. 

so 
```
#..
..#
.#.
```
reads as
```
[
  1,0,0
  0,0,1
  0,1,0
]
```

which results in {row, col} tuples
```
[
  {0,0}
  {1,2}
  {2,1}
]
```

### Find the blank lines
Before we discard the grid we need to identify rows or cols of all zeros.  Rows are easy - just run down the list either summing the row or testing the row for all zeros. 

`Enum.Sum() == 0` is less to type `Enum.all?(row, fn x -> x == 0 end)` is precise and `Enum.any?(row, fn x -> x != 0 end)` has the advantage of not scanning the whole line - Terminating on the first non zero. Coupled with `Enum.reject` this is technically more efficient but as the map is 114 colums both are much the same. 

### Find blank columns
Finding the columns is a little more work as we have to scan across the arrays. 

In theory we could combine with the first row scan and using a reducer and an accumulator of zeros mark each column once we find it is occupied. then count up the results. 

In fact I used a transpose function to turn all the rows into columns and then just list the blank rows.

A third approach is to ignore the grid and just use the coordinates. I think there is a neat algorithm here where we grab the row or col values, sort them and then just add in the expansion as we count up when ever there is a gap.  Treating the rows and cols separately means a O(2N) activity instead of O(N<sup>2</sup>).  If the map was enormous this would be worth following.  But the cost of the sort probably along with debug time makes this a thing for another day.

Building the coordinates is a matter of scanning the rows and columns and outputting a coord tuple for each character.  My version has more maps than necessary I think and could use filter_map if I had more time.

## Distance

Distance is an easy calc we just subtract two points. or rather take the absolute value of the difference between the x's and y's.  As the grid is discrete steps (like a city grid) there is no short diagonal path. Its the same as walking all down the column and across the row. 

## Generate (unique) Pairs

We need to collect the distances between each pair of coordinates. Direction doesn't matter so {0,1}-{2,3} is the same as {2,3}-{0,1}.
My first attempt was to generate all possible pairs and then eliminate the duplicates. 

But this algorithm is neater - we iterate only over the first triangle
```elixir
def generate_pairs(list) do
  Enum.flat_map(0..(length(list) - 2), 
    fn i ->
      Enum.map(i+1..(length(list) - 1), 
        fn j -> {Enum.at(list, i), Enum.at(list, j)} end)
    end)
end

```
It uses Enum.flat_map/2 to iterate over the list from the first element to the second last element. The index of the current element is i.

Inside the Enum.flat_map/2 function, it uses Enum.map/2 to iterate over the rest of the list starting from the next element. The index of the current element is j.

For each pair of elements (i, j), it creates a tuple {Enum.at(list, i), Enum.at(list, j)}. Enum.at/2 is used to get the element at the specified index.

The Enum.map/2 function returns a list of tuples for each i, and Enum.flat_map/2 flattens these lists into a single list of tuples.


## Run

- Process the star map.
- read the file and convert to a grid
- find the blank rows and columns
- build a list of the points
- expand the space between the points
- generate all the pairs of points
- calculate the distance between each pair
- sum the distances

The key step here is expansion. 

Without expansion we can just measure the distances between the coordinates - useful for testing.

To add expansion for each coordinate we compare with the blank rows,cols array to get the count of blanks before this point. Then multiply that count by the expansion coefficient. 

The expansion coefficient is 1 less than the number of lines to replace e.g. 1 means 1 blank becomes 2,  so to replace one with 1 million the coeff is 999_999.

That last bit was what stopped me getting a really short time for part 2. 


# Learnings

- I'm more and more getting to like doctests.  Having the test in the doc comment is great for visibility.  I know python can do this but never really used it.

- replace 2D arrays with lists of coordinates. In other words move towards elements with high information content, vast fields of zeros don't need to be stored just to make indexing convenient. e.g Think vectors not rasters.



