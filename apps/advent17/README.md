# Advent17 -- Day 17: Clumsy Crucible ---

we have a square grid - 141 cells width and height. each cell has a value from 1..9
We need to find a path from the top left to bottom right of the map
we want to minimise the total sum of the cells traversed
cannot go more than 3 steps in a straight line and then must turn left or right

possibilities 
- find an initial path e.g best diagonal
- then adjust the path to see if it generates a lower score.

we need a data structure to easily track paths. 
- we can designate cells as an 2D array of arrays indexed by row and column
- or as a map of cells 0..size indexed by cell id 
- each cell contains the score e.g. { "0" => 2, "1" => 4 .. }
- a set of moves is a cells and scores the sum of the values giving the cost of the path. 

examples:

give 2x2 grid
24
32
we have 2 possible routes 
- 2 r4 d2 = 8
- 2 d3 r2 = 7  - best route

3x3 grid
241
321
325
routes:
2 r4 r1 d1 d5 = 13
2 r4 d2 r1 d5 = 14
2 r4 d2 d2 r5 = 15
2 d3 r2 r1 d5 = 13
2 d3 r2 d2 r5 = 14
2 d3 d3 r2 r5 = 15

best score is 13.  
total number of routes is 6  

Upper bound complexity without constraints is 2^(n-1) * (n-1).  
e.g 4x4 = 2^3 * 3 = 24
13x13 = 2^12 * 12 = 49k
141 ~= 10^44.   

Possible algorithms - both complex to implement
A*, Dijkstra's algorithm (O(V^2)) = 384million (doable)

Testing Assumptions
1. Turning away from the end point i.e going up or right is unlikely to decrease the cost of the path.  

When all cells are 1 all paths are equal cost
18111
18181
11181
11181
88881
in this example the natural path costs 16 crossing the 8. 
but the backtracking path costs 14. so we can go around an obstacle if 4 steps are cheaper than the cost of the cell. e.g 5 surrounded by 1, 6 by 1112 etc. 

2. The data is randomly distributed and doesn't have any perverse low cost maze routes. i.e. this is not a maze solver.  
This doesn't appear to be the case looking at the data. 

3. We can assume that the three step minimum is intended to give us an optimisation 

However at first glance this just complicates the algorithms by expanding the space of state we need to search.

4. What path is found by just taking the lowest cost choice at each turn? 

