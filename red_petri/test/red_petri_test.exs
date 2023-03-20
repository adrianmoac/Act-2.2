defmodule RedPetriTest do
  use ExUnit.Case
  doctest RedPetri

  test "Test de codificación de red de petri con Par Ordenado" do
    assert RedPetri.ord1() == [
      [:P0, :A],
      [:A, :P1],
      [:A, :P2],
      [:P1, :B],
      [:P1, :D],
      [:P2, :C],
      [:P2, :D],
      [:B, :P3],
      [:C, :P4],
      [:D, :P3],
      [:D, :P4],
      [:P3, :E],
      [:P4, :E],
      [:E, :P5]
    ]
  end

  test "Tests de codificación de red de petri con AdHoc" do
    assert RedPetri.adh1() == [
      %RedPetri{postset: [:P1, :P2], preset: [:P0], valor: :A},
      %RedPetri{postset: [:P3], preset: [:P1], valor: :B},
      %RedPetri{postset: [:P4], preset: [:P2], valor: :C},
      %RedPetri{postset: [:P3,:P4], preset: [:P1,:P2], valor: :D},
      %RedPetri{postset: [:P5], preset: [:P3,:P4], valor: :E},
      %RedPetri{postset: [:A], preset: [nil], valor: :P0},
      %RedPetri{postset: [:B,:D], preset: [:A], valor: :P1},
      %RedPetri{postset: [:C,:D], preset: [:A], valor: :P2},
      %RedPetri{postset: [:E], preset: [:B,:D], valor: :P3},
      %RedPetri{postset: [:E], preset: [:C,:D], valor: :P4},
      %RedPetri{postset: [nil], preset: [:E], valor: :P5}
    ]
  end

  test "Tests de enablement con pares Ordenados" do
    assert Ordenados.enablement(RedPetri.ord1, [:P2,:P4]) == [:C]
    assert Ordenados.enablement(RedPetri.ord1, [:P0,:P1,:P2,:P3]) == [:A,:B,:D,:C]
  end

  test "Tests de enablement con estructura AdHoc" do
    assert AdHoc.enablement(RedPetri.adh1, [:P1,:P3,:P4]) == [:B,:E]
    assert AdHoc.enablement(RedPetri.adh1, [:P0,:P1,:P3,:P4]) == [:A,:B,:E]
  end

  test "Tests de replaying con pares Ordenados" do
    assert Ordenados.replaying(RedPetri.ord1,[:P0],"log.txt") == [2, 8]
    assert Ordenados.replaying(RedPetri.ord2,[:P0],"log.txt") == [5, 5]
  end

  test "Tests de replaying con Ad Hoc" do
    assert AdHoc.replaying(RedPetri.adh1,[:P0],"log.txt") == [2, 8]
    assert AdHoc.replaying(RedPetri.adh2,[:P0],"log.txt") == [5, 5]
  end

  test "Tests de la función firing con pares Ordenados" do
    assert Ordenados.firing(RedPetri.ord1,[:P1,:P2],:B) == [:P2,:P3]
    assert Ordenados.firing(RedPetri.ord1,[:P1,:P2,:P4],:D) == [:P3,:P4]
  end

  test "Tests de la función firing con estructura AdHoc" do
    assert AdHoc.firing(RedPetri.adh1,[:P1, :P2],:B) == [:P2,:P3]
    assert AdHoc.firing(RedPetri.adh1,[:P1,:P2,:P4],:D) == [:P3,:P4]
  end

  test "Tests de reachability con pares Ordenados" do
    assert Ordenados.reachability(RedPetri.ord1,[:P0]) == [
      %{m: [:P0], mk: [:P1, :P2], valor: :A},
      %{m: [:P1, :P2], mk: [:P1, :P4], valor: :C},
      %{m: [:P1, :P2], mk: [:P2, :P3], valor: :B},
      %{m: [:P1, :P2], mk: [:P3, :P4], valor: :D},
      %{m: [:P1, :P4], mk: [:P3, :P4], valor: :B},
      %{m: [:P2, :P3], mk: [:P3, :P4], valor: :C},
      %{m: [:P3, :P4], mk: [:P5], valor: :E}
    ]

    assert Ordenados.reachability(RedPetri.ord2,[:P0]) == [
      %{m: [:P0], mk: [:P1, :P2], valor: :A},
      %{m: [:P1, :P2], mk: [:P1, :P4], valor: :C},
      %{m: [:P1, :P2], mk: [:P2, :P3], valor: :B},
      %{m: [:P1, :P4], mk: [:P1, :P2], valor: :D},
      %{m: [:P1, :P4], mk: [:P3, :P4], valor: :B},
      %{m: [:P2, :P3], mk: [:P3, :P4], valor: :C},
      %{m: [:P3, :P4], mk: [:P2, :P3], valor: :D},
      %{m: [:P3, :P4], mk: [:P5], valor: :E}
    ]

    assert Ordenados.reachability(RedPetri.ord3,[:P0]) == [
      %{m: [:P0], mk: [:P1, :P2], valor: :A},
      %{m: [:P1, :P2], mk: [:P1, :P4], valor: :C},
      %{m: [:P1, :P2], mk: [:P2, :P3], valor: :B},
      %{m: [:P1, :P2], mk: [:P3], valor: :D},
      %{m: [:P1, :P4], mk: [:P3, :P4], valor: :B},
      %{m: [:P2, :P3], mk: [:P3, :P4], valor: :C},
      %{m: [:P3, :P4], mk: [:P5], valor: :E}
    ]
  end


  test "Test 1 de reachability con Ad Hoc" do
    assert AdHoc.reachability(RedPetri.adh1,[:P0]) == [
      %{m: [:P0], mk: [:P1, :P2], valor: :A},
      %{m: [:P1, :P2], mk: [:P1, :P4], valor: :C},
      %{m: [:P1, :P2], mk: [:P2, :P3], valor: :B},
      %{m: [:P1, :P2], mk: [:P3, :P4], valor: :D},
      %{m: [:P1, :P4], mk: [:P3, :P4], valor: :B},
      %{m: [:P2, :P3], mk: [:P3, :P4], valor: :C},
      %{m: [:P3, :P4], mk: [:P5], valor: :E}
    ]

    assert AdHoc.reachability(RedPetri.adh2,[:P0]) == [
      %{m: [:P0], mk: [:P1, :P2], valor: :A},
      %{m: [:P1, :P2], mk: [:P1, :P4], valor: :C},
      %{m: [:P1, :P2], mk: [:P2, :P3], valor: :B},
      %{m: [:P1, :P4], mk: [:P1, :P2], valor: :D},
      %{m: [:P1, :P4], mk: [:P3, :P4], valor: :B},
      %{m: [:P2, :P3], mk: [:P3, :P4], valor: :C},
      %{m: [:P3, :P4], mk: [:P2, :P3], valor: :D},
      %{m: [:P3, :P4], mk: [:P5], valor: :E}
    ]

    assert AdHoc.reachability(RedPetri.adh3,[:P0]) == [
      %{m: [:P0], mk: [:P1, :P2], valor: :A},
      %{m: [:P1, :P2], mk: [:P1, :P4], valor: :C},
      %{m: [:P1, :P2], mk: [:P2, :P3], valor: :B},
      %{m: [:P1, :P2], mk: [:P3], valor: :D},
      %{m: [:P1, :P4], mk: [:P3, :P4], valor: :B},
      %{m: [:P2, :P3], mk: [:P3, :P4], valor: :C},
      %{m: [:P3, :P4], mk: [:P5], valor: :E}
    ]
  end

end
