# Advent6 Day 6 Wait For It

This was a simple one. 

Again we start with a parser to read in the source data - but as it is only two lines there is not much work.  I overengineered it though because I thought stage 2 might have a lot more data. 

Then we start with a simple function to calculate the distance_travelled for each press_time given the race time.

```elixir
def distance_travelled press_time, race_time do
    press_time * (race_time - press_time)
  end
```

Then the brute force method is simply to range from 1 to the distance calculating the distance travelled and comparing with the distance limit given. 

I assumed that part 2 would have such large race numbers that we would have to optimise it either by solving the mathematics, or using the fact the curve is parabolic and has a max in the centre - so we could start there and work outwards. 

In the end though the dumb function ran in 2.5 seconds.  So there was no need to go further. 



## Doing it mathematically. 

So we have some spare time to try the algebraic route.

The distance function can be considered to describe a curve varying with time. 
$$press\_time * (race\_time - press\_time)$$

A constant line y = distance intersects the parabola at two points, these points are the solutions to the equation. or rather the two integers inside of these points are the races that beat the distance.

$$-distance + press\_time * (race\_time - press\_time) = 0$$

Arranged into the form $$ax^2 + bx + c = 0$$
$$-press\_time^2 + race\_time*press\_time - distance = 0$$

This is a quadratic equation in the form of , where:

  _a_ = -1 (the coefficient of press_time^2)
  
  _b_ = race_time (the coefficient of press_time)
  
  _-c_ = distance

The solutions to this equation (i.e., the x-coordinates of the intersection points) can be found using the good old quadratic formula:

$$[-b ± sqrt(b^2 - 4ac)] / (2a)$$

Substituting the values of a, b, and c gives:

$$press\_time = [-race\_time ± sqrt(race\_time^2 + 4*distance)] / -2$$

These are the press_times at which the parabola intersects the line y = distance.

Converted to Elixir code we get

```elixir
def calc_race3({time, distance}) do
  part1 = -time / -2
  part2 = :math.sqrt(time * time - 4 * distance) / 2
  :math.floor(part1 + part2) - :math.floor(part1 - part2)
end

assert Advent6.calc_race3({7, 9}) == 4

```

This code runs in constant time for each race and the challenge completes in 0.01 secs.