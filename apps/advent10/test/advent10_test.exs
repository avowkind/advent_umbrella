defmodule Advent10Test do
  use ExUnit.Case
  # doctest Advent10

  test "part 1 test" do
    assert Advent10.run1("data/test1.txt") == 4
  end

  test "part 1 test 2" do
    assert Advent10.run1("data/test2.txt") == 8
  end

  test "part 1 data" do
    assert Advent10.run1("data/data.txt") == 6846
  end

  test "part 2 test" do
    assert Advent10.run2("data/data.txt") == 325
  end
end
