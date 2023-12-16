defmodule Advent15 do
  @moduledoc """
  Documentation for `Advent15`. --- Day 15: Lens Library ---
  """

  @doc """
  Parsing
  read each line into a number array.
  Example:

          iex> Advent15.parse_line("rn=1,cm-,qp=3")
          ["rn=1", "cm-", "qp=3"]
  """
  def parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
  end

  @doc """
  Hash
    Determine the ASCII code for the current character of the string.
    Increase the current value by the ASCII code you just determined.
    Set the current value to itself multiplied by 17.
    Set the current value to the remainder of dividing itself by 256.

  Example:

          iex> Advent15.hash("HASH")
          52
  """
  def hash(str) do
    str
    |> String.to_charlist()  # ascii code
    |> Enum.reduce(0, fn x, acc ->
      x
      |> Kernel.+(acc)
      |> Kernel.*(17)
      |> rem(256)
    end)
  end

  def hash_m(str) do
    str
    |> String.to_charlist()  # ascii code
    |> Enum.reduce(0, fn x, acc ->
      rem((x + acc ) * 17, 256)
      # Bitwise.band((x + acc) * 17, 0xFF)
    end)
  end

  def hash_line(line) do
    line |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def hash_line_m(line) do
    line |> Enum.map(&hash_m/1)
    |> Enum.sum()
  end

  @doc """
  Parsing
  read each file into a number array.
  Example:


  """
  def run1(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
    |> Enum.map(&hash_line/1)
    |> IO.inspect()
  end

  @doc """
    each step begins with a sequence of letters that indicate the label of the lens on which the step operates.
    The result of running the HASH algorithm on the label indicates the correct box for that step.

    rn=1},cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    The label will be immediately followed by a character that indicates the operation to perform: either an equals sign (=) or a dash (-).

    REMOVALS -

    If the operation character is a dash (-),
    go to the relevant box and remove the lens with the given label if it is present
     in the box.

    Then, move any remaining lenses as far forward in the box
    as they can go without changing their order, filling any space made by removing
     the indicated lens. (If no lens in that box has the given label, nothing happens.)

    [ a, b, c, d ] =>  [ a, c, d]  Filter out b

    ADDITIONS =
    If the operation character is an equals sign (=), it will be followed by a number indicating the focal length of the lens that needs to go into the relevant box;
    be sure to use the label maker to mark the lens with the label given in
    { 'r', 'n', 5 }

    APPEND If there is not already a lens in the box with the same label,
     add the lens to the box immediately behind any lenses already in the box.
      Don't move any of the other lenses when you do this.
    [ rest | lens ]

    NEW - If there aren't any lenses in the box,
    the new lens goes all the way to the front of the box.
    [ lens ]


    REPLACE
    If there is already a lens in the box with the same label,
    replace the old lens with the new lens: remove the old lens and put the new lens in its place,
    not moving any other lenses in the box.

    Map() if match { label, focal_length } else x

  """
  def update_box(nil, lens) do
    [lens] end # NEW

  def update_box(lenses, lens) do
    { ll, _} = lens

    {new_lenses, found} = Enum.reduce(lenses, {[], false}, fn
      {label, focal_length}, {acc, found} ->
        if label == ll do
          {[lens | acc], true} # add in place
        else
          {[{label, focal_length} | acc], found}
        end
    end)
    if found do
      Enum.reverse(new_lenses)
    else
      lenses ++ [lens]
    end
  end


  def lensbox(str) do
    str |> Enum.reduce(%{},
      fn x, acc ->
        [[_, label, operation, focal_length]] = Regex.scan(~r/(\w+)([-=])(\d*)/, x)
        box = hash(label)
        lenses = Map.get(acc, box, [])
        case operation do
          "=" -> # UPDATE
            new_box = update_box(lenses, {label, String.to_integer(focal_length)})
            Map.put(acc, box, new_box)
          "-" -> # REMOVE
            new_box = Enum.filter(lenses, fn {l, _} -> l != label end)
            Map.put(acc, box, new_box)
          _ -> IO.inspect("no match")
        end
      end)
  end

  @doc """
  Focussing power

    One plus the box number of the lens in question.
    The slot number of the lens within the box: 1 for the first lens, 2 for the second lens, and so on.
    The focal length of the lens.
  Example:

          iex> Advent15.focussing_power(0, [{"rn", 1}, {"cm", 2}])

  """
  def focussing_power(key, box) do
    box |> Enum.with_index(1)
    |> Enum.reduce(0, fn { {_, focal_length}, index}, acc ->
      (key + 1) * index * focal_length + acc
    end)
  end

  def hash_boxes(line) do
    line |> lensbox() |> Enum.reduce(0, fn {key, box}, acc ->
      focussing_power(key, box) + acc
    end)
  end

  @doc """
  Parsing
  read each file into a number array.
  Example:

            iex> Advent15.run2("data/data.txt")
  """
  def run2(file_path) do
    file_path
    |> File.stream!()
    |> Enum.map(&parse_line/1)
    |> Enum.map(&hash_boxes/1)
    |> IO.inspect()
  end



  ## Extras - hash function timing
  def hash_timing(n) do
    lines = "data/data.txt"
    |> File.stream!()
    |> Enum.map(&Advent15.parse_line/1)

    # part A
    task_a = Task.async(fn ->
      {time_a, _result} = :timer.tc(fn ->
        for _ <- 1..n do
          lines |> Enum.map(&Advent15.hash_line/1)
        end
      end)
      time_a
    end)

    # part B
    task_b = Task.async(fn ->
      {time_b, _result} = :timer.tc(fn ->
        for _ <- 1..n do
          lines |> Enum.map(&Advent15.hash_line_m/1)
        end
      end)
      time_b
    end)

    time_a = Task.await(task_a)
    time_b = Task.await(task_b)
    { time_a, time_b}
  end

end
