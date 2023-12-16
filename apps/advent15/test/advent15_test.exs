defmodule Advent15Test do
  use ExUnit.Case
  doctest Advent15

  test "hash" do
    assert Advent15.hash("HASH") == 52
  end

  @tag timeout: 3600000
  test "hash function timing" do
    # run hash_timing function N times and collate the results
    # then print the average time
    count = 10
    times = Enum.map(1..count, fn _ ->
      Advent15.hash_timing(1000)
    end)
    # IO.inspect(times)

    differences = Enum.map(times, fn {a, b} -> a - b end)
    |> IO.inspect()

    min = differences |> Enum.min()
    max = differences |> Enum.max()
    mean = differences |> DescriptiveStatistics.mean()
    stdev = differences |> DescriptiveStatistics.standard_deviation()

    IO.puts("Min: #{min}, Max: #{max}, Mean: #{mean}, Standard Deviation: #{stdev}")

  end
end
