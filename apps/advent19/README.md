# Advent19


Part 2

We have a workflow data structure

Expressed in the source file as a set of rules.

px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

We parse these rules into a map of tuples

%{
   in: {[{:s, :<, 1351, :px}], :qqz},
   qkq: {[{:x, :<, 1416, :A}], :crn},
   px: {[{:a, :<, 2006, :qkq}, {:m, :>, 2090, :A}], :rfg},
   rfg: {[{:s, :<, 537, :gd}, {:x, :>, 2440, :R}], :A},
   pv: {[{:a, :>, 1716, :R}], :A},
   lnx: {[{:m, :>, 1548, :A}], :A},
   gd: {[{:a, :>, 3333, :R}], :R},
   qs: {[{:s, :>, 3448, :A}], :lnx},
   crn: {[{:x, :>, 2662, :A}], :R},
   qqz: {[{:s, :>, 2770, :qs}, {:m, :<, 1801, :hdj}], :R},
   hdj: {[{:m, :>, 838, :A}], :pv}
 }

Each map key is the identifier of a rule. 

A rule has the structure
{ [ comparison_array ], else_rule }
example: {[{:a, :<, 2006, :qkq}, {:m, :>, 2090, :A}], :rfg}

the comparison_array is between 1 and 4 tuples with the structure { letter, operator, value, match_rule }

keys, letters, operators and match_rules are all atoms.

letters must be one of :x, :m, :a, :s.  
operators are either :< or :> less than or greater than.
values are integers in the range 1..4000



input to a rule is a tuple giving a value for each of :x, :m, :a, :s.   e.g. %{s: 2876, m: 2655, a: 1222, x: 787},

to process a rule we run through the comparison array in sequence performing the comparison,  e.g :a, :<, 2006 if this is true we have completed the rule and move onto the match_rule given e.g. {:a, :<, 2006, :qkq} means if a < 2006 goto :qkq.  if false try the next rule in the sequence, if no rules match then goto the else_rule e.g :rfg.

this function will take an input tuple and a rule and return the next rule

```elixir
  def process_rule({workflow, last}, rating) do
    workflow
    |> Enum.reduce_while(last, fn {xmas, op, opand, next}, last ->
      case op do
        :< ->
          if rating[xmas] < opand do
            {:halt, next}
          else
            {:cont, last}
          end
        :> ->
          if rating[xmas] > opand do
            {:halt, next}
          else
            {:cont, last}
          end
        nil ->
          {:halt, {:error, "no op"}}
      end
    end)
  end
```

The chain of rules terminates when the returned match rule is either :A or :R.  :A means accepted, :R means rejected. 

The rules link together into a directed acyclic graph. the root rule is identified as :in.  and the terminal leaves of the tree are identified as :A or :R.

Given the input rating record `%{s: 2876, m: 2655, a: 1222, x: 787}` we start with the :in rule and recursively follow rules until we get to :A or :R.

```elixir
  def process_rating(rating, workflows, rule \\ :in) do
    case rule do
      :R -> { :R, rating}
      :A -> { :A, rating}
      _ ->
        next_rule = process_rule(workflows[rule], rating)
        process_rating(rating, workflows, next_rule)
    end
  end

```

The goal is to find which of all possible input combinations of x,m,a,s in the range 1..4000 lead to the :A terminus. 

There are too many possible inputs for us to test each input directly so we need an algorithm that will reduce the graph of rules down to a single record giving a list of the upper and lower bands for each letter that result in :A results. 
e.g
%{ x: [ {100,200}, {500,505}], m: [ {1001,2001}] etc.}

Remember multiple paths may lead to the terminal nodes. 

Start by outlining some algorithms that might be applied to solve this problem


To solve this problem, we can use a combination of depth-first search (DFS) and dynamic programming. Here's a high-level outline of the algorithm:

Initialize an empty map to store the range of values for each letter that leads to the :A terminus.
Start a DFS from the root rule :in.
In the DFS, for each rule:
If the rule is :A, update the map with the current values of x, m, a, s.
If the rule is :R, ignore and continue with the next rule.
If the rule is a comparison rule, recursively call DFS on the next rule based on the comparison result.
After the DFS, the map will contain the range of values for each letter that leads to the :A terminus.