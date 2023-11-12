-module(exceptions).

-export([try_exception/1, catch_all/1]).

try_exception(Data) ->
    try converter:to_rub(Data) of 
        {ok, _Amount} = Result ->
            io:format("No exeptions, result: ~p~n", [Result]),
            Result
    catch
        throw:{error, invalid_data} ->
            io:format("Exception happened~n"); 
        error:Reason ->
            io:format("Exception error happened, reason: ~p~n", [Reason]);
        _:Reason ->
            io:format("Unknown exception, reason: ~p~n", Reason)
    end.

catch_all(Action) when is_function(Action, 0) ->
  try Action() of
    Result -> {ok, Result}
  catch
    throw:Reason ->
      io:format("Action ~p failed, reason ~p ~n", [Action, Reason]),
      throw;
    error:Reason ->
      io:format("Action ~p failed, reason ~p ~n", [Action, Reason]),
      error;
    exit:Reason ->
      io:format("Action ~p failed, reason ~p ~n", [Action, Reason]),
      exit;
    _:_ ->
      io:format("We covered all cases so this line will never be printed~n"),
      "Never will happen"
  end.
