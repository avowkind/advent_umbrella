# Advent18


We need a very fast area calculation of a non convex rectilinear shape for which we have a list of corner coordinates. 

might there be an algorithm that finds each concave point e.g. one where the previous point is on an earlier column of the same row and the next is on the same column but a lower row. We then take the rectangle formed by these three points and while keeping its area in a list replace the concave point with its opposite corner. Adding the equivalent area to the shape. If we repeat this until there are no concave corners we should be left with only 4 corners and can calculate the area of the rectangle, by subtracting the saved rectangles we should get our interiour area

decomposition into rectangles

Initialize an empty list to store the areas of the rectangles (rectangle_areas).
While there are concave points in the polygon:
Find a concave point (concave_point).
Determine the rectangle formed by concave_point, the previous point on the same row, and the next point on the same column.
Calculate the area of the rectangle and add it to rectangle_areas.
Replace concave_point with its opposite corner in the rectangle.
Once there are no more concave points, calculate the area of the remaining rectangle (remaining_area).
Subtract the sum of rectangle_areas from remaining_area to get the interior area of the polygon.

Might there be a turtle graphics type of algorithm. If instead of the list of corners we have a length and a turn Left, Right, Up or Down? might there be a fast algorithm using this data?