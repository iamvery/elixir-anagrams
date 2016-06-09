defmodule Anagram.AlphagramTest do
  use ExUnit.Case
  doctest Anagram.Alphagram

  test "contains?" do
    assert Anagram.Alphagram.contains?(["a", "b"],      ["a"])      == true
    assert Anagram.Alphagram.contains?(["a", "b"],      ["b"])      == true
    assert Anagram.Alphagram.contains?(["a", "b"],      ["c"])      == false
    assert Anagram.Alphagram.contains?(["a", "b"],      ["a", "b"]) == true
    assert Anagram.Alphagram.contains?(["a", "g"],      ["a", "b"]) == false
    assert Anagram.Alphagram.contains?(["a", "b"],      ["a", "a"]) == false
    assert Anagram.Alphagram.contains?(["a", "a", "b"], ["a", "a"]) == true
    assert Anagram.Alphagram.contains?(["a", "b"],      [])         == true
    assert Anagram.Alphagram.contains?([],              ["a", "b"]) == false
  end

  test "without" do
    assert Anagram.Alphagram.without(["a"                ], [])         == ["a"]
    assert Anagram.Alphagram.without(["a"                ], ["a"])      == []
    assert Anagram.Alphagram.without(["a", "a"           ], ["a"])      == ["a"]
    assert Anagram.Alphagram.without(["a", "a"           ], ["a", "a"]) == []
    assert Anagram.Alphagram.without(["a", "b", "c", "d" ], ["b", "c"]) == ["a", "d"]
  end

end