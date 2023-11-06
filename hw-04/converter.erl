-module(converter).
-record(conv_info,{
	type,
	amount,
	commission
}).

-export([to_rub/1, to_rub2/1, to_rub3/1, rec_to_rub/1, map_to_rub/1]).


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

to_rub(_) ->
    io:format("Invalid currency or amount~n"),
 {error, badarg}.


to_rub2({Type, Amount} = Arg) ->
  Result = 
    case Arg of
        {usd, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [usd, Amount]),
			{ok, 75.5 * Amount};
		{euro, Amount} when is_integer(Amount), Amount > 0 ->
			io:format("Convert ~p to rub, amount: ~p~n", [euro, Amount]),
			{ok, 80 * Amount};
		{lari, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [lari, Amount]),
			{ok, 29 * Amount};
		{peso, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [peso, Amount]),
			{ok, 3 * Amount};
		{krone, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [krone, Amount]),
			{ok, 10 * Amount};
	    Error ->
		io:format("Can't convert to rub, error ~p~n", [Error]),
			{error, badarg}
    end,
    io:format("Converted ~p to rub, amount ~p, Result ~p~n", [Type, Amount, Result]),
    Result.


to_rub3(Arg) ->
    case Arg of
        {usd, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [usd, Amount]),
			{ok, 75.5 * Amount};
		{euro, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [euro, Amount]),
			{ok, 80 * Amount};
		{lari, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [lari, Amount]),
			{ok, 29 * Amount};
		{peso, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [peso, Amount]),
			{ok, 3 * Amount};
		{krone, Amount} when is_integer(Amount), Amount > 0 -> 
			io:format("Convert ~p to rub, amount: ~p~n", [krone, Amount]),
			{ok, 10 * Amount};
	    Error ->
		io:format("Can't convert to rub, error ~p~n", [Error]),
		{error, badarg}
     end.

rec_to_rub(#conv_info{type = usd, amount = Amount, commission = Commission})
	when is_integer(Amount), Amount > 0 ->
		ConvAmount = Amount * 75.5,
		CommissionResult = ConvAmount * Commission,
		Result = ConvAmount - CommissionResult,
	io:format("Convert ~p to rub, Result: ~p~n", [usd, Result]),
	{ok, Result};
rec_to_rub(#conv_info{type = euro, amount = Amount, commission = Commission})
	when is_integer(Amount), Amount > 0 ->
		ConvAmount = Amount * 80,
		CommissionResult = ConvAmount * Commission,
		Result = ConvAmount - CommissionResult,
	io:format("Convert ~p to rub, Result: ~p~n", [euro, Result]),	
	{ok, Result};
rec_to_rub(#conv_info{type = lari, amount = Amount, commission = Commission})
	when is_integer(Amount), Amount > 0 ->
		ConvAmount = Amount * 29,
		CommissionResult = ConvAmount * Commission,
		Result = ConvAmount - CommissionResult,
	io:format("Convert ~p to rub, Result: ~p~n", [lari, Result]),
	{ok, Result};
rec_to_rub(#conv_info{type = peso, amount = Amount, commission = Commission})
	when is_integer(Amount), Amount > 0 ->
		ConvAmount = Amount * 3,
		CommissionResult = ConvAmount * Commission,
		Result = ConvAmount - CommissionResult,
	io:format("Convert ~p to rub, Result: ~p~n", [peso, Result]),
	{ok, Result};
rec_to_rub(#conv_info{type = krone, amount = Amount, commission = Commission})
	when is_integer(Amount), Amount > 0 ->
		ConvAmount = Amount * 10,
		CommissionResult = ConvAmount * Commission,
		Result = ConvAmount - CommissionResult,
	io:format("Convert ~p to rub, Result: ~p~n", [krone, Result]),
	{ok, Result};
rec_to_rub(#conv_info{} = Info) ->
	io:format("Can't convert to rub, error ~p~n", [Info]),
	{error, badarg}.


map_to_rub(#{type := usd, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 75.5,
    CommissionResult = Result * Commission,
    {ok, Result - CommissionResult};
map_to_rub(#{type := euro, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 80,
    CommissionResult = Result * Commission,
    {ok, Result - CommissionResult};
map_to_rub(#{type := lari, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 29,
    CommissionResult = Result * Commission,
    {ok, Result - CommissionResult};
map_to_rub(#{type := peso, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 3,
    CommissionResult = Result * Commission,
    {ok, Result - CommissionResult};
map_to_rub(#{type := krone, amount := Amount, commission := Commission}) when is_integer(Amount), Amount > 0 ->
    Result = Amount * 10,
    CommissionResult = Result * Commission,
    {ok, Result - CommissionResult};
map_to_rub(Map) ->
    io:format("Can't convert to rub, invalid currency ~p~n", [Map]),
    {error, badarg}.







