defmodule Advent5Test do
  use ExUnit.Case
  doctest Advent5
# @source """
#   seeds: 79 14 55 13

#   seed-to-soil map:
#   50 98 2
#   52 50 48

#   soil-to-fertilizer map:
#   0 15 37
#   37 52 2
#   39 0 15

#   fertilizer-to-water map:
#   49 53 8
#   0 11 42
#   42 0 7
#   57 7 4

#   water-to-light map:
#   88 18 7
#   18 25 70

#   light-to-temperature map:
#   45 77 23
#   81 45 19
#   68 64 13

#   temperature-to-humidity map:
#   0 69 1
#   1 0 69

#   humidity-to-location map:
#   60 56 37
#   56 93 4
#   """
#   test "parse_input" do

#     lines = String.split(@source, "\n", trim: true)
#     assert Advent5.parse_input(lines) == %{
#       current: :toloc,
#       seeds: [79, 14, 55, 13],
#       tosoil: [[50, 98, 2], ~c"420"],
#       tofertilizer: [[0, 15, 37], [37, 52, 2], [39, 0, 15]],
#       tohumid: [[0, 69, 1], [1, 0, 69]],
#       tolight: [[88, 18, 7], [18, 25, 70]],
#       toloc: [~c"<8%", [56, 93, 4]],
#       totemp: [[45, 77, 23], [81, 45, 19], ~c"D@\r"],
#       towater: [~c"15\b", [0, 11, 42], [42, 0, 7], [57, 7, 4]]
#     }
#   end

#   test "line_to_integers" do
#     assert Advent5.line_to_integers("1 32 3  4 5") == [1, 32, 3, 4, 5]
#   end

#   test "parse_ints" do
#     acc = %{ current: :c, c: []}
#     assert Advent5.parse_ints("11 32 3  4 5", acc) ==
#       %{ current: :c, c: [[11, 32, 3, 4, 5]]}
#   end
#   test "parse_ints2" do
#     acc = %{ current: :towater, towater: [[1,2]]}
#     assert Advent5.parse_ints("11 32 3  4 5", acc) ==
#       %{ current: :towater, towater: [[1,2],[11, 32, 3, 4, 5]]}
#   end

  test "check_one" do
    sdr = [50, 98, 2]
    assert Advent5.check_one(sdr,1) == 1
    assert Advent5.check_one(sdr,51) == 51
    assert Advent5.check_one(sdr,98) == 50
    assert Advent5.check_one(sdr,99) == 51
    assert Advent5.check_one(sdr,100) == 100
  end

  test "check_one2" do
    sdr = [52, 50, 48]
    assert Advent5.check_one(sdr,1) == 1
    assert Advent5.check_one(sdr,50) == 52
    assert Advent5.check_one(sdr,51) == 53
    assert Advent5.check_one(sdr,52) == 54
  end
  test "check_seed" do
    tosoil = [[50, 98, 2], [52, 50, 48]]
    assert Advent5.check_seed(1, tosoil) == 1
    assert Advent5.check_seed(50, tosoil) == 52
    assert Advent5.check_seed(51, tosoil) == 53
    assert Advent5.check_seed(98, tosoil) == 50
    assert Advent5.check_seed(99, tosoil) == 51
    assert Advent5.check_seed(100, tosoil) == 100
  end

  test "check_seed_layer" do
    table = File.stream!("data/data2.txt") |> Advent5.parse_input()
    assert Advent5.check_seed(98, table[:tosoil]) == 50
    assert Advent5.check_seed(18, table[:tolight]) == 88
    assert Advent5.check_seed(24, table[:tolight]) == 94
    assert Advent5.check_seed(25, table[:tolight]) == 18
  end

  test "check_all_layers" do
    IO.puts("\ncheck_all_layers\n")
    table = File.stream!("data/data2.txt") |> Advent5.parse_input()
    assert Advent5.all_layers(79, table) == 82
    assert Advent5.all_layers(14, table) == 43
    assert Advent5.all_layers(55, table) == 86
    assert Advent5.all_layers(82, table) == 46
  end
  test "do_seeds" do
    IO.puts("\ndo_seeds\n")
    table = File.stream!("data/data2.txt") |> Advent5.parse_input()
    seeds = table[:seeds]
    assert Advent5.do_seeds(seeds, table) == 35
  end

  # test "part1" do
  #   part1 = Advent5.part1()
  #   IO.puts("part1 #{part1}")
  #   assert Advent5.part1() == 486613012
  # end


  @tag timeout: :infinity
  test "part2" do
    x = Advent5.part2()
    IO.puts("part2 #{x}")
  end

    # test "counts " do
    # assert Advent5.counttrys() == 1966850685
    # end
end
