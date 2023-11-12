-module(converter).

-export([to_rub/1]).


to_rub({usd, Amount}) when is_integer(Amount), Amount > 0 ->
	io:format("Convert ~p to rub, amount ~p~n", [usd, Amount]),
 {ok, Amount * 75.5};
to_rub({euro, Amount}) when is_integer(Amount), Amount > 0 ->
	io:format("Convert ~p to rub, amount ~p~n", [euro, Amount]),
 {ok, Amount * 80};
to_rub({lari, Amount}) when is_integer(Amount), Amount > 0 ->
	io:format("Convert ~p to rub, amount ~p~n", [lari, Amount]),
 {ok, Amount * 29};
to_rub({peso, Amount}) when is_integer(Amount), Amount > 0 ->
	io:format("Convert ~p to rub, amount ~p~n", [peso, Amount]),
 {ok, Amount *3};
to_rub({krone, Amount}) when is_integer(Amount), Amount > 0 ->
	io:format("Convert ~p to rub, amount ~p~n", [krone, Amount]),
 {ok, Amount * 10};

to_rub({_, _Amount}) ->
	throw({error, invalid_data}).

