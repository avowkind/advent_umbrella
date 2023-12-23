defmodule Advent19 do
  @moduledoc """
  Documentation for `Advent19`.


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

  {x=787,m=2655,a=1222,s=2876}
  {x=1679,m=44,a=2067,s=496}
  {x=2036,m=264,a=79,s=2244}
  {x=2461,m=1339,a=466,s=291}
  {x=2127,m=1623,a=2188,s=1013}
  """

  @doc """
  parse the rule input line
  assume conditions only <> and not =
  Example:

        iex> Advent19.parse_rule("tq{m<2648:A,A}")
        {:tq,
          {[
            {:m, :<, 2648, :A},
          ],
          :A}
        }
        iex> Advent19.parse_rule("px{a<2006:qkq,m>2090:A,rfg}")
        {:px,
          {[
            {:a, :<, 2006, :qkq},  # first rule
            {:m, :>, 2090, :A}     # second rule
          ],
          :rfg  }                 # catch all
        }
  """
  def parse_rule(line) do
    regex = ~r/(\w+){(.*),(\w+)}/
    [[ label, rules, last]] = Regex.scan(regex, line, capture: :all_but_first)
    rules = rules
    |> String.split(",", trim: true)
    |> Enum.map(fn rule ->
      case Regex.run(~r/(\w+)([<>])(\d+):(\w+)/, rule) do
        [_, xmas, op, opand, next ] ->
          {String.to_atom(xmas), String.to_atom(op), String.to_integer(opand), String.to_atom(next)}
        _ ->
          {String.to_atom(rule), nil, nil, nil}
      end
    end)
    { String.to_atom(label), {rules, String.to_atom(last)}}
  end

  @doc """
  parse the second part

  Example:

          iex> Advent19.parse_xmas("x=787,m=2655,a=1222,s=2876")
          %{a: 1222, m: 2655, s: 2876, x: 787}
  """
  def parse_xmas(line) do
    regex = ~r/(\w+)=(\d+)/
    Regex.scan(regex, line, capture: :all_but_first)
    |> Enum.map(fn [key, value] -> {String.to_atom(key), String.to_integer(value)} end)
    |> Enum.into(%{})
  end

  @doc """
  process rule
  given rule {[{:s, :<, 1351, :px}], :qqz}
  and rating %{a: 1222, m: 2655, s: 2876, x: 787}
  return the next rule to process or :A or :R

  Example:
          iex> Advent19.process_rule({[{:s, :<, 1351, :px}], :qqz}, %{a: 1222, m: 2655, s: 2876, x: 787})
          :qqz

          iex> Advent19.process_rule({[{:s, :>, 1351, :px}], :qqz}, %{a: 1222, m: 2655, s: 2876, x: 787})
          :px

          # %{a: 1, m: 2, s: 3, x: 4})
          iex> Advent19.process_rule({[{:s, :>, 2, :mp}, {:m, :>, 10, :A}, {:a, :>, 10, :A}], :qhp}, %{a: 1, m: 2, s: 3, x: 4})
          :mp

          iex> Advent19.process_rule({[{:s, :>, 3, :mp}, {:m, :<, 10, :mm}, {:a, :>, 10, :A}], :qhp}, %{a: 1, m: 2, s: 3, x: 4})
          :mm

          iex> Advent19.process_rule({[{:s, :>, 3, :mp}, {:m, :>, 10, :mm}, {:a, :<, 2, :aa}], :qhp}, %{a: 1, m: 2, s: 3, x: 4})
          :aa

          iex> Advent19.process_rule({[{:s, :>, 3, :mp}, {:m, :>, 10, :mm}, {:a, :>, 2, :aa}], :qhp}, %{a: 1, m: 2, s: 3, x: 4})
          :qhp
  """
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

  @doc """
  process workflow

  """
  def process_rating(rating, workflows, rule \\ :in) do
    case rule do
      :R -> { :R, rating}
      :A -> { :A, rating}
      _ ->
        next_rule = process_rule(workflows[rule], rating)
        process_rating(rating, workflows, next_rule)
    end
  end


  def parse_file(filename) do
    File.stream!(filename)
    |> Enum.split_while(&(&1 != "\n"))
    |> case do
      {before_blank, after_blank} ->
        workflows = before_blank
        |> Enum.map(&parse_rule/1)
        |> IO.inspect(label: 'workflows', limit: :infinity)
        |> Enum.into(%{})
        # |> IO.inspect(label: 'workflows')

        ratings = after_blank
        |> Stream.drop(1)  # Drop the blank line
        |> Enum.map(&parse_xmas/1)
        { workflows, ratings}
    end
  end

  def sum_rating({ _, rating}) do
    rating
    |> Map.values()
    |> Enum.sum()
  end

  def run(filename) do
    { workflows, ratings } = filename |> Advent19.parse_file()
    # IO.inspect( { length(workflows), length(ratings)}, label: 'lengths')
    IO.inspect(workflows, label: 'workflows', limit: :infinity)
    IO.inspect(ratings, label: 'ratings', limit: :infinity)

    ratings
    |> Enum.map(fn rating ->
      Advent19.process_rating(rating, workflows)
    end)
    |> IO.inspect(label: 'ratings', limit: :infinity)
    |> Enum.filter(fn {key, _} -> key == :A end)
    |> IO.inspect(label: 'filtered',limit: :infinity)
    |> Enum.map(&sum_rating/1)
    |> IO.inspect(label: 'sums', limit: :infinity)

    |> Enum.sum()
    |> IO.inspect(label: 'sum')

  end
    def find_A_ranges(workflows) do
      initial_values = %{x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000}
      search(workflows, :in, %{}, initial_values)
      |> count_patterns()
    end

    defp search(_workflows, :A, ranges, values) do
      IO.inspect({values, ranges}, label: 'found A')
      Map.merge(values, ranges, fn
        _k, v1, v2 -> [v1, v2] |> List.flatten() |> Enum.uniq()
      end)
      |> IO.inspect(label: 'merged')
    end

    defp search(_workflows, :R, ranges, _values), do: ranges
    defp search(workflows, rule, ranges, values) do
      {comparisons, else_rule} = workflows[rule]
      IO.inspect({rule, comparisons, else_rule}, label: 'search comparisons')
      new_ranges = Enum.reduce(comparisons, ranges, fn {letter, op, val, next}, acc ->
        IO.inspect({letter, op, val, next}, label: 'search flat_map')
        if !valid_comparison?(values[letter], op, val) do
          new_values = update_values(values, letter, op, val)
          IO.inspect(new_values, label: 'new_values')
          Map.update(acc, letter, [], fn old ->
            [old, search(workflows, next, acc, new_values)]
            |> List.flatten()
            |> Enum.uniq()
          end)
        else
          acc
        end
      end)
      IO.puts('using else')
      Map.update(new_ranges, else_rule, [], fn old ->
        [old, search(workflows, else_rule, new_ranges, values)]
        |> List.flatten()
        |> Enum.uniq()
      end)
    end

    defp valid_comparison?(value, :<, val), do: Enum.max(value) < val
    defp valid_comparison?(value, :>, val), do: Enum.min(value) > val

    defp update_values(values, letter, :<, val) do
      IO.inspect({values, letter, val}, label: '< update_values')
      Map.put(values, letter, Enum.min(values[letter])..min(Enum.max(values[letter]), val))
    end

    defp update_values(values, letter, :>, val) do
      IO.inspect({values, letter, val}, label: '> update_values')
      Map.put(values, letter, max(Enum.min(values[letter]), val)..Enum.max(values[letter]))
    end

    defp count_patterns(ranges) do
      Enum.reduce(ranges, 1, fn {_key, range}, acc ->
        acc * (Enum.count(Enum.to_list(range)))
      end)
    end
  end
