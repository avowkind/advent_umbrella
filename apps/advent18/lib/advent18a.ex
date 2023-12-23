defmodule Advent18a do
  @moduledoc """
  Documentation for `Advent18a  Part 2`.

  stream the lines into a list of steps

  Walk through the list of steps, keeping track of the current position and direction.
  extract any left turns into a list of negative rectangles

  """
  def parse_line(line) do
    Regex.scan(~r/(\w) (\d+) \((#[a-fA-F0-9]{6})\)/, line)
    |> List.first()
    |> case do
      [_, dir, steps, _] -> {dir, String.to_integer(steps)}
      _ -> :error
    end
  end
  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(fn line -> parse_line(line) end)
  end

  ## PART 2

  @doc """
  Convert the colour to a move
    #70c710 = R 461937
    #0dc571 = D 56407
    #5713f0 = R 356671
    #d2c081 = D 863240
    #59c680 = R 367720
    #411b91 = D 266681
    #8ceee2 = L 577262
    #caa173 = U 829975
    #1b58a2 = L 112010
    #caa171 = D 829975
    #7807d2 = L 491645
    #a77fa3 = U 686074
    #015232 = L 5411
    #7a21e3 = U 500254

  Example
          iex> Advent18a.parse_line2("R 6 (#70c710)")
          {"R", 461937}
  """
  def parse_line2(line) do
    Regex.scan(~r/\w \d+ \(#([a-fA-F0-9]{5})([0-3]{1})\)/, line)
    |> List.first()
    |> case do
      [_, length, direction] ->
        # direction 0 means R, 1 means D, 2 means L, and 3 means U.
        direction = case direction do
          "0" -> "R"
          "1" -> "D"
          "2" -> "L"
          "3" -> "U"
        end
        # convert length as a HEX number
        { direction, String.to_integer(length,16)}
      _ -> :error
    end

  end

 @doc """
  Parsing
  read each line into a coordinate map
  Example:

          iex> Advent18a.parse_file2("data/test.txt")
          [
              {"R", 461937},
              {"D", 56407},
              {"R", 356671},
              {"D", 863240},
              {"R", 367720},
              {"D", 266681},
              {"L", 577262},
              {"U", 829975},
              {"L", 112010},
              {"D", 829975},
              {"L", 491645},
              {"U", 686074},
              {"L", 5411},
              {"U", 500254}
            ]

  """
  def parse_file2(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(fn line -> parse_line2(line) end)
  end


  def build_graph(plan) do
    plan
    |> Enum.reduce( {{0,0}, [{0,0}]},
      fn {dir, steps}, {{row,col}, acc} ->
          next = case dir do
            "R" -> {row, col+steps}
            "L" -> {row, col-steps}
            "U" -> {row-steps, col}
            "D" -> {row+steps, col}
          end
          IO.inspect(next, label: "next")

          { next, [ next | acc ]}
      end)
      |> then(fn {_, acc} -> Enum.reverse(acc) end)
      |> IO.inspect()
  end

  @doc """
  reducing rectangles



  U a R b,   |- - right turn
    shift left



  """
  def turn( step, {prev, racc,moves} ) do
    # IO.inspect({prev, step, racc}, label: "\nturn[")
    {d1, a} = prev
    {d2, b} = step
    left_turn = fn() -> racc + (a * b) end
    slip_slop = fn() ->
      if a < b do {{ d2, b-a}, racc + (0 - a ), moves}
      else
        {{ d1, a-b}, racc + (0 - b ), moves}
      end
    end
    case {d1, d2} do
      {"R", "U"} -> { prev,  left_turn.(), [ step | moves] }
      {"U", "L"} -> { prev,  left_turn.(), [ step | moves] }
      {"L", "D"} -> { prev,  left_turn.(), [ step | moves] }
      {"D", "R"} -> { prev,  left_turn.(), [ step | moves] }
      {"R", "R"} -> { { "R", a+b}, racc, moves }
      {"U", "U"} -> { { "U", a+b}, racc, moves }
      {"L", "L"} -> { { "L", a+b}, racc, moves }
      {"D", "D"} -> { { "D", a+b}, racc, moves }

      {"U", "D"} -> slip_slop.()
      {"D", "U"} -> slip_slop.()
      {"L", "R"} -> slip_slop.()
      {"R", "L"} -> slip_slop.()
      _ ->
        { step, racc,  [ prev | moves] }
    end
    # |> IO.inspect(label: "turn]")
  end


  @doc """
  Walk through the list of steps, keeping track of the current position and direction.
  extract any left turns into a list of negative rectangles

  ## Example
          iex> Advent18a.parse_file2("data/test.txt")

  # |> Advent18a.reduce_rects()
  """
  def reduce_rects( graph, acc\\0) do
    # IO.inspect(graph, label: "reduce_rects [")
    [ first | tail ] = graph
    tail |> Enum.reduce({first, acc, []}, &turn(&1, &2)) # prev, rects, moves

    |> then(fn { last, racc, moves} ->
      moves = Enum.reverse([last | moves])
        # IO.inspect({racc, moves}, label: "reduce_rects ]")
        {moves, racc}
    end)
  end

  # 1407374123584  -  454969182101 = 952408144115
  def sum_rects({rects, racc}) do
    # IO.inspect({rects, racc}, label: "sum_rects [")
    dim = Enum.reduce(rects, %{}, fn {key, value}, acc ->
      Map.update(acc, key, value, &(&1 + value))
    end)
    # IO.inspect(dim, label: "dim")
    area = (dim["R"]+1) * (dim["D"] + 1)
    covered = area - racc
    IO.puts("area: #{area}, covered: #{covered}")
  end

  def run_reduce_rects(graph, acc, 0), do: {graph, acc}
  def run_reduce_rects(graph, acc, n) do
    {new_graph, new_acc} = reduce_rects(graph, acc)
    run_reduce_rects(new_graph, new_acc, n - 1)
  end

  def shoelace_formula1(vertices) do
    vertices
    |> Enum.concat([List.first(vertices)])
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce({0, 0}, fn [{x1, y1}, {x2, y2}], {sum1, sum2} ->
      {sum1 + x1 * y2, sum2 + x2 * y1}
    end)
    |> then(fn {sum1, sum2} -> abs(sum1 - sum2) / 2 end)
  end

  def shoelace_formula(vertices) do
    vertices
    |> Enum.chunk_every(2, 1, vertices)
    |> Enum.map(fn [{lx, ly}, {rx, ry}] -> lx * ry - rx * ly end)
    |> Enum.sum()
    |> then(fn x -> div(abs(x), 2) end)
  end

  def picks(vertices) do
    area = shoelace_formula(vertices)
    boundary_points = boundary_points(vertices)
    area - div(boundary_points, 2) + 1 + boundary_points
  end

  def boundary_points(vertices) do
    vertices
    |> Enum.chunk_every(2, 1, vertices)
    |> Enum.map(fn
      [{lx, y}, {rx, y}] -> abs(lx - rx)
      [{x, ly}, {x, ry}] -> abs(ly - ry)
    end)
    |> Enum.sum()
  end

end
