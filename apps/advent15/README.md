# Advent15 --- Day 15: Lens Library ---

Part one of this was very simple, done in 15 mins and most of that reading the instructions. 

## Hash code
To calculate the has we break the string into character list; which is the ascii code or more accurately the unicode code point.
Then perform a simple reducer to sum and multiply

This is the pipeline version:
```Elixir

  def hash(str) do
    str 
    |> String.to_charlist()  # ascii code
    |> Enum.reduce(0, fn x, acc ->
      x
      |> Kernel.+(acc)
      |> Kernel.*(17)
      |> rem(256)
    end)
  end
```  

And the more mathematical version
```Elixir

  def hash(str) do
    str 
    |> String.to_charlist()  # ascii code
    |> Enum.reduce(0, fn x, acc ->
      rem((x + acc ) * 17, 256)
    end)
  end
```  

### Performance digression

I was curious whether there was any noticable difference between using the pipe operator compared with the more usual notation. So added a test that runs the two hash versions about a million times and compares the time differences. I run the two timer loops in tasks concurrently to speed it up - but this may of course add a degree of variation to the results. 
results in microseconds. 
Min: -14279, Max: 17381, Mean: -247.675, Standard Deviation: 1495

Basically no difference at all.  This makes sense - any compiler worth its salt is going to boil both versions down to the same assembler code.  So which form is used is a matter of notational convenience


However, replacing the rem with an AND 0xFF is a consistently a bit faster:
Min: 8537, Max: 45092, Mean: 22497.25, Standard Deviation: 1691

on average this version is 22ms faster for 1000 hashes.

On the other hand - for all I know the compiler might spot we are running the same hash again and remember the previous result.

## Back to the plot, Part 2

See the comment for update box. 
Essentially we read each rule in the string e.g rm=1 and carry out one of a set of actions, creating, updating, or deleting lenses from each box.  

Noting that the labels are not of consistent length e.g rm=, asdc= etc. I opted for a regex to pick out the label, operation and value as this handled the optional focal_length value neatly

I do like these ~ strings that Elixir has.  

`~r/(\w+)([-=])(\d*)/`

### Boxes
Usually here one would use a mutable array of 256 length placing in each slot an array to hold the details of each lens.  We use the label hash to get the box index. 

I used a map %{} where we add each box with a key for the box number
and the value being an array of tuples holding the label and focal length of each lens

e.g `{ 1: [ {"rm", 1}, { "cp", 2 }]}`

While Array.at is available, each access is a linear linked list search.  Elixir's Map data structure is built on top of Erlang's Map, which is implemented as a hash array mapped trie (HAMT) ( I looked that up).  This gives a constant time lookup.  Again it doesn't really matter much but it does feel fairly natural to only add boxes to the list as and when they get used. 

Of course the entries are not ordered sequentially but with numbers as the keys we could easily use a range to iterate through the list. 

However, the final calculation does NOT require us to go through the list in order. its a simple sum of each box value so we can just run the map through a reducer. 

The focussing power calculation is elegantly expressed, with_index gives us the lenses paired with their index handily available for the multiplication. 

```Elixir
 def focussing_power(key, box) do
    box |> Enum.with_index(1)
    |> Enum.reduce(0, fn { {_, focal_length}, index}, acc ->
      (key + 1) * index * focal_length + acc
    end)
  end
```


# Learnings

### Tuples

We have tuples in Javascript and Python of course but here they are the primary mode of passing things around. I think this is encouraged by the ease of matching and I have notices this pattern appearing in my Python code now. 

Without good documentation though you wouldn't for example know that a parameter being passed in is expected to be { x,y }.  We can add @spec annotations but these don't really name the fields.  If we want names we can create structs and maps but in many cases why bother. 

### Reducers

It seems like everything is either a map - N in, N out,  or a reducer - N in, anything out. 

