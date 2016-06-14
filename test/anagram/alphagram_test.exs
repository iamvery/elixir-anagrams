defmodule Anagram.AlphagramTest do
  use ExUnit.Case
  doctest Anagram.Alphagram

  test "converting a string to an alphagram" do
    assert Anagram.Alphagram.to_alphagram("nappy") == [:a, :n, :p, :p, :y]
  end

  test "converting a string to an alphagram and removing illegal codepoints" do
    # Assumes default legal codepoints
    assert Anagram.Alphagram.to_alphagram("nappy?!!") == [:a, :n, :p, :p, :y]

    is_legal_codepoint? = fn (codepoint) ->
      <<codepoint_val::utf8>> = codepoint
      codepoint_val in (?b..?z)
    end
    assert Anagram.Alphagram.to_alphagram("nappy?!!", is_legal_codepoint?) == [:n, :p, :p, :y]

    is_legal_codepoint? = fn (codepoint) ->
      <<codepoint_val::utf8>> = codepoint
      codepoint_val in [?a, ?p]
    end

    assert Anagram.Alphagram.to_alphagram("nappy?!!", is_legal_codepoint?) == [:a, :p, :p]
  end

  test "subtracting nothing from a list" do
    assert Anagram.Alphagram.without(["a"                ], [])         == {:ok, ["a"], []}
  end

  test "subtracting everything from a one-item list" do
    assert Anagram.Alphagram.without(["a"                ], ["a"])      == {:ok, [], ["a"]}
  end

  test "subtracting everything from a multi-item list" do
    assert Anagram.Alphagram.without(["a", "a"           ], ["a", "a"]) == {:ok, [], ["a", "a"]}
  end

  test "subtracting the first item from a list" do
    assert Anagram.Alphagram.without(["a", "a"           ], ["a"])      == {:ok, ["a"], ["a"]}
  end

  test "subtracting some items from different parts of a list" do
    assert Anagram.Alphagram.without(["a", "b", "c", "d" ], ["b", "d"]) == {:ok, ["a", "c"], ["b", "d"]}
  end

  test "trying to subtract an item that's not in the list" do
    assert Anagram.Alphagram.without(
      ["a", "b"], ["x"]
    ) == {:error, "outer does not contain all letters of inner", {["a", "b"], ["x"]}}
  end

end
