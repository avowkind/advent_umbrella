defmodule Advent11 do
  @moduledoc """
  Documentation for `Advent11`.
  """

  @doc """
  Parsing
  read each line into a number array.

  Example:

          iex> Advent11.parse_line("...#......")
          [0, 0, 0, 1, 0, 0, 0, 0, 0, 0]
  """
  def parse_line(line) do
    line
    |> String.trim()
    |> String.codepoints()
    # replace . with 0 and # with 1
    |> Enum.map(fn "." -> 0; "#" -> 1 end)
  end

  def parse_file(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
  end

@doc """
read the test file into lines
Example:

        iex> Advent11.parse_file("data/test.txt")
        [
              [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
              [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
              [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
              [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
              [1, 0, 0, 0, 1, 0, 0, 0, 0, 0]
            ]
"""
def test_file() do
  parse_file("data/test.txt")
end

@doc """
find the indexes of the blank rows

Example:

          iex> Advent11.list_blank_rows([
          ...>      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          ...>      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          ...>      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          ...>      [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
          ...>    ])
          [1, 2]
"""
def list_blank_rows_1(grid) do
  grid
  |> Enum.with_index()
  |> Enum.filter(fn {row, _} -> Enum.all?(row, fn x -> x == 0 end) end)
  |> Enum.map(fn {_, i} -> i end)
end

def list_blank_rows(grid) do
  grid
  |> Enum.with_index()
  |> Enum.reject(fn {row, _} -> Enum.any?(row, fn x -> x != 0 end) end)
  |> Enum.map(fn {_, i} -> i end)
end

@doc """
transpose an array of arrays - found on stack overflow
Example:

        iex> Advent11.transpose([[1,2],[3,4],[5,6]])
        [[1, 3, 5], [2, 4, 6]]
"""
def transpose([[] | _]), do: []
def transpose(m) do
  [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
end



@doc """
count blank rows and columns

Example:
        iex> Advent11.get_empty_lines([
        ...>      [1, 0, 0, 0],
        ...>      [0, 0, 1, 0],
        ...>      [0, 0, 0, 0],
        ...>      [0, 0, 0, 0],
        ...>    ])
        { [2,3], [1,3] }
"""
def get_empty_lines(grid) do
  rows = grid |> list_blank_rows()
  cols = grid |> transpose() |> list_blank_rows()
  {rows, cols}
end



@doc """
Iterate across the grid picking out each 1 along with its row and column
resulting in a list of tuples of the form {row, col, n} with n increasing.

Example:
        iex> Advent11.build_list([
        ...>      [1, 0, 1],
        ...>      [0, 1, 0],
        ...>      [1, 0, 1],
        ...>    ])
        [
          {0, 0},
          {0, 2},
          {1, 1},
          {2, 0},
          {2, 2}
        ]
"""
def build_list(grid) do
  grid
  |> Enum.with_index()
  |> Enum.map(fn {row, row_index} ->
    row
    |> Enum.with_index()
    |> Enum.map(fn {n, col_index} ->
      {row_index, col_index, n}
    end)
  end)
  |> List.flatten()
  |> Enum.filter(fn {_, _, n} -> n == 1 end)
  # drop the n
  |> Enum.map(fn {row, col, _} -> {row, col} end)
end

@doc """
Calculate the distance between two points

Example:
        iex> Advent11.distance({{0, 0}, {1, 1}})
        2
        iex> Advent11.distance({{4, 4}, {0, 0}})
        8
"""
def distance({{x1, y1}, {x2, y2}}) do
  abs(x1 - x2) + abs(y1 - y2)
end

@doc """
Generate all the pairs of points in the grid
this will result in duplicates
Example:
        iex> Advent11.generate_pairs([
        ...>      {0, 0},
        ...>      {0, 2},
        ...>      {1, 1},
        ...>      {2, 0},
        ...>      {2, 2}
        ...>    ])
        [
          {{0, 0}, {0, 2}},
          {{0, 0}, {1, 1}},
          {{0, 0}, {2, 0}},
          {{0, 0}, {2, 2}},
          {{0, 2}, {1, 1}},
          {{0, 2}, {2, 0}},
          {{0, 2}, {2, 2}},
          {{1, 1}, {2, 0}},
          {{1, 1}, {2, 2}},
          {{2, 0}, {2, 2}}
        ]
"""
def generate_pairs(list) do
  Enum.flat_map(0..(length(list) - 2), fn i ->
    Enum.map(i+1..(length(list) - 1), fn j ->
      {Enum.at(list, i), Enum.at(list, j)}
    end)
  end)
end


@doc """
Process the star map.
read the file and convert to a grid
find the blank rows and columns
build a list of the points
expand the space between the points
generate all the pairs of points
calculate the distance between each pair
sum the distances
"""
def run(filename, expansion) do
  grid = filename |> parse_file()

  blanks = get_empty_lines(grid)

  grid
    |> build_list
    # inflation
    |> Enum.map(fn {row, col} ->
      {rows, cols} = blanks
      row = row + expansion * Enum.count(Enum.filter(rows, fn x -> x < row end))
      col = col + expansion * Enum.count(Enum.filter(cols, fn x -> x < col end))
      {row, col}
    end)
  |> generate_pairs()
  |> Enum.map(&distance/1)
  |> Enum.sum()
end

end
