defmodule Advent11Test do
  use ExUnit.Case
  doctest Advent11

  test "test 1" do
    assert Advent11.run("data/test.txt",1) == 374
    assert Advent11.run("data/test.txt", 999_999) == 82000210
  end
  test "test 2" do
    assert Advent11.run("data/test2.txt", 0) == 18
    assert Advent11.run("data/test2.txt", 1) == 25
    assert Advent11.run("data/test2.txt", 999_999) == 7000011
  end

  test "run 1" do
    assert Advent11.run("data/data.txt", 1) == 9521550
  end

  test "run 2" do
    assert Advent11.run("data/data.txt", 999_999) == 298932923702
  end
end
