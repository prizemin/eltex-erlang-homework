-module(recursion).

-export([tail_fac/1, duplicate/1, tail_duplicate/1]).

tail_fac(N) ->
    tail_fac(N, 1).

tail_fac(0, Acc) ->
   Acc;
tail_fac(N, Acc) when N > 0 ->
    io:format("factorial ~p~n", [N]),
    tail_fac(N-1, Acc * N).


duplicate([]) -> []; 

duplicate([Head | Tail]) ->
    [Head, Head | duplicate(Tail)].


tail_duplicate(List) ->
    tail_duplicate(List, []).

tail_duplicate([], Acc) ->
    lists:reverse(Acc);
tail_duplicate([Head | Tail], Acc) ->
    tail_duplicate(Tail, [Head, Head | Acc]).