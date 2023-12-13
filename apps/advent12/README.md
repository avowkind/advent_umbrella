# Advent12 - Day 12: Hot Springs

However, the condition records are partially damaged; some of the springs' conditions are actually unknown (?). For example:

???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1

Equipped with this information, it is your job to figure out how many different arrangements of operational and broken springs fit the given criteria in each row.

So we have two main things to do
1 - matching - to eliminate the known patterns
2 - counting permutations. 

Matching:
(???.### 1,1,3) the 3 has to match with the ### so the 1,1 must match with the ???
as there must be a space between them we have ?.? 1,1  and there is only one permutation.

Permutations
.??..??...?##. 1,1,3 - the ## must match with the 3 so the ? is the rest of the 3.
this means ?? = 1 and ?? = 1

?? = 1 means pick one from two
combination formula : C(m, n) = m! / [n!(m - n)!]

??..?? 1,1 is either pick 2 from 4 or pick 1 from 2 twice.
C(2,4) = 4! / (2!(4-2)!) = 4! / (2! * 2!) = 24 / (2 * 2) = 6
2 * C(1,2) = 2 x 2 = 4.   

?###???????? 3,2,1 the 3 matches ### so we have 8 ? 
they must be separated and 

Given ???????? 
we must pick a group of 2 followed by a 1
what is the formula for the number of combinations

The number of combinations for picking a group of 2 followed by 1 from m items would be:
C(m, 2) * C(m-2, 1)
C(6, 2) * C(6-2, 1) = 15 * 4 = 60
This is the wrong answer as the 2 has to be before the 1 so the group is constrained

rule to place 2,1  in 8 
lets letter the slots
ABCDEFGH
take the first two positions and leave a space 
slots = 8  
**_       the 1 can be in any of the remaining positions 

aa_bbbbb   b1 = 8 - 2 - 1 = 5   then move the first 2 over
_aa_bbbb   b2 = b1 -1     = 4   repeat
__aa_bbb   b3 = b2 - 1    = 3
___aa_bb   b4 = b3 - 1    = 2
____aa_b   b5 = b3 - 1    = 1   no more positions. 

5 + 4 + 3 + 2 + 1  = 15  = n * (n + 1) / 2 

however I got the start wrong the first ? must be a . so we have 7 slots
so the choices are 4,3,2,1 = 10. 

general patterns

### case 1 = a single pattern sliding in a single band.
given ????  of length m
and   aa of length n 
the number of positions is the same as shortening m by n-1 ( m - (n-1))

e.g ??????? = 7
    aaa     = 3
     aaa
      aaa
       aaa
        aaa

5 positions  7 - (3-1) = 5. 

def positions_in_slots({pos, slots}) do
  slots - (pos -1 )
end


### case 2 = two patterns sharing a band

e.g slots = 7   a = 2, b = 1
(slots - b + 1) == (slots - b - 1) no brackets

the end point is where b cannot move right and there must be a space there so the slot for a is (slots - b - 1) = 5
positions for 
a_width = (slots - b - 1) = ( 7 - 1 - 1) = 5
a = slots - pos + 1 = 2 in 5 (5-2+1)= 4 
b_width = (slots - a - 1) = ( 7 - 2 - 1) = 4
_aa_bbbb   b2 = b1 -1     = 4   repeat
__aa_bbb   b3 = b2 - 1    = 3
___aa_bb   b4 = b3 - 1    = 2
____aa_b   b5 = b3 - 1    = 1

positions for b
b = slots - pos + 1  = 4 - 1 + 1 = 4 

as a moves 4 times the result is 4 + 3 + 2 + 1 = 10.

### but if a=2 and b=2
a_width = (slots - b - 1) = 7 - 2 - 1 = 4
a = 3 positions. 
b_width = (slots - (a + 1)) 7 - (2 + 1) = 4
b = b_slots - pos + 1 = 4 - 2 + 1 = 3 positions
then as the space closes we again go 3 + 2 + 1 = 6
result = 6 positions
perms = n * (n + 1) / 2  = 3 * 4 /2 = 6

check
1234567
aa bb   1
aa  bb  2
aa   bb 3
 aa bb  4
 aa  bb 5
  aa bb 6
1234567

### but if a=2 and b=3

a_width = (slots - b - 1) = 7 - 3 - 1 = 3
a = a_width - a + 1 = 3 - 2 + 1 = 2
b_width = (slots - a - 1)) 7 - 2 - 1 = 4
b = b_width - b + 1 = 4 - 3 + 1 = 2 positions
1234567
aa bbb   1
aa  bbb  2
 aa bbb  3
1234567
= 2 + 1 = 3

another way to look at it 
if a = 2 and b =3 in 7 then this is the same as 
a = 1, b = 1 in 7 - a - b + 2 = 7 - 2 - 3 + 2  = 4
then positions = b single moves in 4 - 2 = 2 
1234
a b
a  b
 a b 
b pos = width - pos + 1 = 2 - 1 + 1 = 2 
perms = n * (n + 1) / 2  = 2 * 3 /2 = 3

pos = width - a - 1 = 4 - 1 - 1 = 4

I think it may always be constrained by the right most position

e.g 
123456789  a=2, b = 2, c = 1
a? b? c??   only 3 remain for c so if c =1 there are 3 + 2 + 1 final positions. 

however having removed c we reduce the band by c+1
123456789
aa bb ccc  * 3
aa  bb cc  * 2
aa   bb c  * 1
 aa bb cc  * 2
 aa  bb c  * 1
  aa bb c  * 1
= 10 

is this the same as reducing them to singles
so subtract 2 and a = 1, b=1
1234567
a b ccc   * 3
a  b cc   * 2
a   b c   * 1
 a b cc   * 2
 a c  c   * 1
  a b c   * 1 
= 10.

so with 4 items
having subtracted extras
1234567
a b c d = 1 solution. 
becuase we subtract abc * 2 = 6 leaving 1.

with more space
1234567890
a b c dddd = 4 => 10  n * (n + 1) / 2 
a  b c ddd = 3 =>  6
a   b c dd = 2 =>  3 counts the cs 
a    b c d = 1 =>  1   3 in 8 = 20 
 a etc

2 in 6        m in n 
is 1 in 4
is 4,3,2,1  = 10 

123456
a bbbb = 4  = 6 - 2  = m - n 
a  b
3 in 8 = 20  f(4) = 4+3+2+1 + 3+2+1 + 2+1  + 1 
               10 +  6  + 3     1 = 20
2 in 6 = 

1 in 4 =  4 

  def f(n) when is_integer(n) and n > 0 do
    Enum.sum(for i <- 1..n, do: i * (i + 1) / 2)
  end
  def f(n) when is_integer(n) and n > 0 do
    Enum.sum(for i <- 1..n, do: i * (n - i + 1))
  end
  f(4) = 4*1 + 3*2 + 2*3 + 1*4 = 20
  f(5) = 5*1 + 4*2 + 3*3 + 2*4 + 1*5
  f(x) = x*1 + (x-1)*2 etc. 

  when there is 1 item in n spaces there are n solutions
  f(1, n) = n 

  when there are 2 items in n spaces with no gaps
  n + n-1 + n-2 ...  = n * (n + 1) / 2
  f(2,2) = ab = 1  1*2/2 = 1
  f(2,3) = ab. a.b .ab = 3  ( 2  + 1)
  f(2,4) = (3+2+1) = 6 = 3*4/2 
  f(2,5) = 10 = 4*5/2
  f(2,n) = (n-1) + n / 2 

  when there are 3 items in n spaces no gaps
  f(m,n)
  f(3,3) = 1  n must be at least m 
  f(3,4) 
  abcc 2
  a.bc 1 f(2,3) = 3
  .abc 1 f(2,2) = 1 = 4
  f(3,5) = 9
    abccc 3 
    a bcc 2 
    a  bc 1 f(2,4) =6
     abcc 2 
     a bc 1 f(2,3) =3 
      abc 1 f(2,2) =1
  f(3,n) = f(3-1,n-1) + f(3-1, n-2) + f(3-1, n-3)
  
  having removed the spaces we are just picking n from m
  C(m, n) = m! / [n!(m - n)!]

Looking up in the elixir book
  Math.k_permutations(n, k) The number of distinct ways to create groups of size k from n distinct elements.
Math.k_combinations(n, k) The number of distinct ways to create groups of size k from n distinct elements where order does not matter.

I think we want combinations.

4 in 8
a.b.c.d.
a.b.c..d
a.b..c.d
a..b.c.d
.a.b.c.d



@doc """
  if the two arrays are different lengths then we need to
  try to eliminate any solid matches until they are the same length

  Example:

          iex> Advent12.match_and_remove({["???", "###"], [1, 1, 3]})
          {["???"], [1, 1]}

          iex> Advent12.match_and_remove({["###", "???"], [3, 1, 1]})
          {["???"], [1, 1]}

          iex> Advent12.match_and_remove({["????", "######", "#####"], [1, 6, 5]},)
          {["????"], [1]}
  """
  # this regex matches #?#? type patterns
  #  re = ~r/^[?#]{#{n}}$/

def match_and_remove({code, points}) do
  # does the length of the head match the length of the points head
  [code_head | code_tail] = code
  [points_head | points_tail] = points
  if String.length(code_head) == points_head do
      # if so return the tail and the points tail
      {code_tail, points_tail}
  else
    # otherwise return the code and the points
    List.last()
    {code, points}
  end
end

  @doc """
  if the two arrays are different lengths then we need to
  break the longer array into smaller arrays and try to match_equals with each pair. if we succeed we
  e.g   {["???", "###"], [1, 1, 3]}
  is tested with [[1,1], 3] , [[1], [1,3]]
  Example:
          iex> Advent12.pair_lists({["???", "###"], [1, 1, 3]})
          [ [ {"???",[1]}, {"###",[1,3]}],
          [ {"???",[1,1]}, {"###",[3]}] ]

[
  [{"?AA", [1]}, {"BBB", [2, 3]}],
  [{"?AA", [1,2]}, {"BBB", [3]}]
]
  """
  def pair_lists({a, b}) do
    combinations = generate_combinations(b)
    Enum.map(combinations, fn combination ->
      Enum.zip(a, combination)
    end)
  end

