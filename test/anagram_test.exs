defmodule AnagramTest do
  Code.load_file("basic_anagram_user.ex", "test")
  Code.load_file("custom_anagram_user.ex", "test")
  use ExUnit.Case
  doctest Anagram

  test "can find the only possible anagrams using a tiny dictionary" do
    result = BasicAnagramUser.anagrams_of("onto", ["on", "to"])
    assert result == ["on to"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = BasicAnagramUser.anagrams_of("On, To!", ["on", "to"])
    assert result == ["on to"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = BasicAnagramUser.anagrams_of("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["race car", "race arc", "care car", "care arc"]
  end

  test "can handle duplicate words in the input phrase" do
    result = BasicAnagramUser.anagrams_of("apple racecar apple", ["race", "car", "apple", "racecar"])
    assert result == ["car apple race apple", "apple racecar apple"]
  end

  test "can find words with apostrophes, like 'I'm'" do
    result = BasicAnagramUser.anagrams_of("I'm cool", ["I'm", "cool", "mi"])
    assert result == ["cool mi", "cool I'm"]
  end

  test "uses the built-in default dictionary if none is specified" do
    assert BasicAnagramUser.anagrams_of("onto") == BasicAnagramUser.anagrams_of("onto", :default)
  end

  test "can find anagrams using the built-in default dictionary" do
    result = BasicAnagramUser.anagrams_of("onto")
    assert result == ["onto", "no to", "on to", "ton o", "not o"]
  end

  test "can find anagrams using a dictionary defined in the user's module" do
    result = CustomAnagramUser.anagrams_of("spear", :tiny)
    assert result == ["spear", "spare", "reaps", "pears", "parse", "pares"]
  end

  test "uses legal_codepoints as defined in the user's module" do
    result = CustomAnagramUser.anagrams_of("mañana", :tiny_spanish)
    assert result == ["mañana", "ña mana", "maña na"]
  end

  test "human_readable builds a 'cartesian join' of words the alphagrams can spell" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((Anagram.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end

  def ag(str), do: Anagram.Alphagram.to_alphagram(str)
  def ags(list), do: Enum.map(list, &ag/1)

  test "expand expands the search tree by one level" do
    phrase = ag("onto")
    dict   = ags(["hi", "to", "on", "not"])
    found  = ags([])
    filtered = ags(["to", "on", "not"])
    assert(Anagram.expand(phrase, dict, found)) == [
      [ found: ags(["to" ]), phrase: ag("on"), dict: ags(["to", "on", "not"])],
      [ found: ags(["on" ]), phrase: ag("to"), dict: ags(["on", "not"])],
      [ found: ags(["not"]), phrase: ag("o"),  dict: ags(["not"])],
    ]
  end

  test "expand adds to the list of found words" do
    phrase = ag("onto")
    dict   = ags(["hi", "to", "on", "not"])
    found  = ags(["boat"])
    filtered = ags(["to", "on", "not"])
    assert(Anagram.expand(phrase, dict, found)) == [
      [ found: ags(["to" , "boat"]), phrase: ag("on"), dict: ags(["to", "on", "not"])],
      [ found: ags(["on" , "boat"]), phrase: ag("to"), dict: ags(["on", "not"])],
      [ found: ags(["not", "boat"]), phrase: ag("o"),  dict: ags(["not"])],
    ]
  end
end
