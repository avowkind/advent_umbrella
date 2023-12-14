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

then score the rocks by position

first we want to read the table and transpose so that we can operate on one row at a time.

then slide each rock to the left until it hits the head or a #
then score them and sum the rows.

aborted slide left as it needs many recursive calls
  def slide_left([ a, b | [] ]) do
    # at the end of the list just return the last element
    { x, y } = move_O_left(a, b)
    [x, y]
  end
  def slide_left([ a, b | tail ]) do
    # take the first two elements
    # return the first element, then recurse with the remaining list with the new head
    { x, y } = move_O_left(a, b)
    [ x | slide_left([y | tail]) ]
  end

  instead split into shorter arrays on the 2. 
  count the number of 1s in each group and generate the sum
  e.g. 
  [0,1,0,2, 0, 1,2,0,0,0]
  [0,1,0], [0,1], [0,0,0]
  10 9 8  7 6 5  4 3 2 1
  reverse the list and map with index
      |> Enum.with_index()
  then
  


"""
With the hash of each grid, we can now detect the cycle
which may occur.  We can use a map to store the hash and
the number of times it has occurred.  When we detect a cycle
we can then calculate the number of times we need to repeat
the cycle to get to the 1000000000th iteration.
