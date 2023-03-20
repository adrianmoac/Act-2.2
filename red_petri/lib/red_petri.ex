defmodule RedPetri do

  defstruct preset: [nil], valor: nil, postset: [nil]
  def transiciones, do: [:A, :B, :C, :D, :E]

  #Definición de la red de petri Ejercicio 1
  def ord1 do
    [
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

  def adh1 do
    [
      %RedPetri{preset: [:P0], valor: :A, postset: [:P1, :P2]},
      %RedPetri{preset: [:P1], valor: :B, postset: [:P3]},
      %RedPetri{preset: [:P2], valor: :C, postset: [:P4]},
      %RedPetri{preset: [:P1,:P2], valor: :D, postset: [:P3,:P4]},
      %RedPetri{preset: [:P3,:P4], valor: :E, postset: [:P5]},
      %RedPetri{valor: :P0, postset: [:A]},
      %RedPetri{preset: [:A], valor: :P1, postset: [:B,:D]},
      %RedPetri{preset: [:A], valor: :P2, postset: [:C,:D]},
      %RedPetri{preset: [:B,:D], valor: :P3, postset: [:E]},
      %RedPetri{preset: [:C,:D], valor: :P4, postset: [:E]},
      %RedPetri{preset: [:E], valor: :P5}
    ]
  end

  #Definición de la red de petri Ejercicio 2
  def ord2 do
    [
      [:P0, :A],
      [:A, :P1],
      [:A, :P2],
      [:P1, :B],
      [:P2, :C],
      [:B, :P3],
      [:D, :P2],
      [:C, :P4],
      [:P3, :E],
      [:P4, :E],
      [:P4, :D],
      [:E, :P5]
    ]
  end

  def adh2 do
    [
      %RedPetri{preset: [:P0], valor: :A, postset: [:P1, :P2]},
      %RedPetri{preset: [:P1], valor: :B, postset: [:P3]},
      %RedPetri{preset: [:P2], valor: :C, postset: [:P4]},
      %RedPetri{preset: [:P4], valor: :D, postset: [:P2]},
      %RedPetri{preset: [:P3,:P4], valor: :E, postset: [:P5]},
      %RedPetri{valor: :P0, postset: [:A]},
      %RedPetri{preset: [:A], valor: :P1, postset: [:B]},
      %RedPetri{preset: [:A, :D], valor: :P2, postset: [:C]},
      %RedPetri{preset: [:B], valor: :P3, postset: [:E]},
      %RedPetri{preset: [:C], valor: :P4, postset: [:D, :E]},
      %RedPetri{preset: [:E], valor: :P5}
    ]
  end

  #Definición de la red de petri Ejercicio 3
  def ord3 do
    [
      [:P0, :A],
      [:A, :P1],
      [:A, :P2],
      [:P1, :B],
      [:P1, :D],
      [:P2, :C],
      [:P2, :D],
      [:B, :P3],
      [:D, :P3],
      [:C, :P4],
      [:P3, :E],
      [:P4, :E],
      [:E, :P5]
    ]
  end

  def adh3 do
    [
      %RedPetri{preset: [:P0], valor: :A, postset: [:P1, :P2]},
      %RedPetri{preset: [:P1], valor: :B, postset: [:P3]},
      %RedPetri{preset: [:P2], valor: :C, postset: [:P4]},
      %RedPetri{preset: [:P1,:P2], valor: :D, postset: [:P3]},
      %RedPetri{preset: [:P3,:P4], valor: :E, postset: [:P5]},
      %RedPetri{valor: :P0, postset: [:A]},
      %RedPetri{preset: [:A], valor: :P1, postset: [:B,:D]},
      %RedPetri{preset: [:A], valor: :P2, postset: [:C, :D]},
      %RedPetri{preset: [:B, :D], valor: :P3, postset: [:E]},
      %RedPetri{preset: [:C], valor: :P4, postset: [:E]},
      %RedPetri{preset: [:E], valor: :P5}
    ]
  end

end

#Funciones medilast pares ordenados
defmodule Ordenados do
  def firing(ord1, puntos, t) do
    if ((preset(ord1, t) -- puntos) == []) do
      Enum.sort(Enum.uniq(postset(ord1, t) ++ (puntos -- preset(ord1, t))))
    else
      puntos
    end
  end

  def enablement([], _puntos), do: []
  def enablement([a|b], puntos) do
    if((preset(RedPetri.ord1, hd(tl(a))) -- puntos) == []) do
      Enum.uniq([hd(tl(a))] ++ enablement(b, puntos))
    else
      enablement(b, puntos)
    end
  end

  def replay1(_ord2, _puntos, []), do: 1
  def replay1(ord2, puntos, [a|b]) do
    nuevoPunto = firing(ord2,puntos,String.to_atom(a))
    if (nuevoPunto == puntos) do
      0
    else
      replay1(ord2,nuevoPunto,b)
    end
  end

  def replay2(_ord2, _puntos, []), do: 0
  def replay2(ord2, puntos, [a|b]) do
    replay1(ord2, puntos, a) + replay2(ord2, puntos, b)
  end

  def replaying(ord2, puntos, file) do
    lista =
    File.read!(file)
    |> String.split
    |> Enum.map(fn li -> String.split(li, ",") end)
    t = replay2(ord2,puntos,lista)
    [t] ++ [length(lista) - t]
  end

  def nodes(_ex,_puntos,_last,[]), do: []
  def nodes(rd,puntos,last,tr) do
    [a|b] = tr;
    if(((preset(rd,a)) -- puntos) == []) do
      nuevo = firing(rd, puntos, a)
      if(last != nuevo) do
        Enum.uniq([%{m: puntos, valor: a, mk: nuevo}] ++ nodes(rd,puntos,last, b) ++ nodes(rd,nuevo,puntos,RedPetri.transiciones))
      else
        Enum.uniq([%{m: puntos, valor: a, mk: nuevo}] ++ nodes(rd,puntos,last, b))
      end
    else
      nodes(rd, puntos,last, b)
    end
  end

  def reachability(ord3, puntos) do
    Enum.sort(nodes(ord3, puntos,[], RedPetri.transiciones))
  end

  def preset([],_t), do: []
  def preset(rd, t) do
    [a|b] = rd
      if (hd(tl(a)) == t) do
        [hd(a)] ++ preset(b, t)
      else
        preset(b, t)
      end
  end

  def postset([],_t), do: []
  def postset(rd, t) do
    [a|b] = rd
    if (hd(a) == t) do
      [hd(tl(a))] ++ postset(b, t)
    else
      postset(b, t)
    end
  end

end

#Funciones medilast Ad Hoc
defmodule AdHoc do
  def firing(adh1, puntos, t) do
    nodo = buscar(adh1, t)
    if ( (nodo.preset -- puntos) == []) do
      Enum.sort(Enum.uniq(nodo.postset ++ (puntos -- nodo.preset)))
    else
      puntos
    end
  end

  def enablement([], _puntos), do: []
  def enablement([a|b], puntos) do
    if((a.preset -- puntos) == []) do
      [a.valor] ++ enablement(b, puntos)
    else
      enablement(b, puntos)
    end
  end

  def replay1(_adh2, _puntos, []), do: 1
  def replay1(adh2, puntos, [a|b]) do
    nuevoPunto = firing(adh2,puntos,String.to_atom(a))
    if (nuevoPunto == puntos) do
      0
    else
      replay1(adh2,nuevoPunto,b)
    end
  end

  def replay2(_adh2, _puntos, []), do: 0
  def replay2(adh2, puntos, [a|b]) do
    replay1(adh2, puntos, a) + replay2(adh2, puntos, b)
  end

  def replaying(adh2, puntos, file) do
    lista =
    File.read!(file)
    |> String.split
    |> Enum.map(fn li -> String.split(li, ",") end)
    t = replay2(adh2,puntos,lista)
    [t] ++ [length(lista) - t]
  end

  def nodes(_ex,_puntos,_last,[]), do: []
  def nodes(rd,puntos, last,tr) do
    [a|b] = tr
    transiciones = buscar(rd, a)
    if(( transiciones.preset -- puntos) == []) do
      nuevo = firing(rd, puntos, a)
      if(last != nuevo) do
        Enum.uniq([%{m: puntos, valor: a, mk: nuevo}] ++ nodes(rd,puntos,last, b) ++ nodes(rd,nuevo,puntos,RedPetri.transiciones))
      else
        Enum.uniq([%{m: puntos, valor: a, mk: nuevo}] ++ nodes(rd,puntos,last, b))
      end
    else
      nodes(rd, puntos,last, b)
    end
  end

  def reachability(adh3, puntos) do
    Enum.sort(nodes(adh3, puntos,[], RedPetri.transiciones))
  end

  def buscar([a|b], t) do
    if(a == []) do
      %RedPetri{}
    else
      if (a.valor == t) do
        a
      else
        buscar(b, t)
      end
    end
  end

end
