# Advent7 Day 7 Camel Cards

I really liked this one. Took about 3 hours for both parts.  I'm sure there are other ways to do this but I liked my numeric algorithm. 

I started down a path of identifying the hand types before realising that we just needed a sortable value for each hand.  

So my algorithm replaces each char with a number, then groups them into a list of tuples {card, count} ( thanks Enum.group_by). sorts them and then we only need to look at the first 2 results e.g five of a kind = [{ A, 5}, {B, 1}] while full house is [ {A, 3}, {B,2}]

We can combine into a score by effectively making 3, 2 -> 32, but as there are 13 symbols we raise the first value by 13. `[a,b] -> a * @base + b`.  

A side function converts the resulting values into a hand type `3 * @base + 2 => :full_house,` It is not needed for the answer but helps with check/debug.

Two hands of the same type also have to be ranked on the card values so we have a similar function that turns the hand into a 5 element base 13 value represented by its decimal value. We need to combine both scores with the hand rank being more significant so the final score for a hand is `rank_hand(hand) * (13 ** 5) + hand_strength(hand)`.

With this score we can rank all the hands, index them and multiply by the bid to get the result. 

I'm finding Elixir's list functions super useful in these exercises. It seems all the solutions are variants of map/reduce. I love the notation for piping a chain of small functions together. A() |> B() |> C().  rather than having to do C(B(A())) or use a lot of locals. 

## Part 2
Part 2 with the jokers was straightforward; given the representation I had chosen I just needed to take any  {J, c} tuple in my hand and add its count to the first (highest count) item.  The one exceptional case was with 5 Jokers. here I used a separate def to handle the special case: 

```elixir
def jokers([{9,5}]) do
  IO.puts("jackpot!")
  [{9,5}]
  end
```

Elixir uses pattern matching very effectively and allows multiple functions with the same name, and parameters to exist side by side - choosing the one that matches the input pattern.  Its a great way to handle edge cases and keeps the main function very clean.  Reminds me of Eiffel contracts in a way. 

