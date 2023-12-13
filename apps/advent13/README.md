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

we can quickly compare the rows by either 
scanning the chars - or perhaps converting to binary and comparing number. We are good up to about 64 bits. So I decided to convert . to 0 and # to 1 then compress into a single number array e.g [102, 90, 385, 385, 90, 102, 346]
This paid off later

its possible for there to be no matches in the rows or columns but and neither would be a zero.

Part 2

we are already finding the nearly matched centres
