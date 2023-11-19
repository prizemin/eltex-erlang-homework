-module(keylist).

-export([loop/1]).
-export([start_monitor/1]).
-export([start_link/1]).
-export([stop/1]).

-record(state,{
  list = [],
  counter = 0
}).

start_monitor(Name) when is_atom(Name) ->
  {Pid, MonitorRef} = spawn_monitor(?MODULE, loop, [#state{}]),
  io:format("Started pid ~p ~n", [Pid]),
  register(Name, Pid),
  {ok, Pid, MonitorRef}.

start_link(Name) when is_atom(Name) ->
  Pid = spawn_link(?MODULE, loop, [#state{}]),
  io:format("Linked pid ~p ~n", [Pid]),
  register(Name, Pid),
  {ok, Pid}.

stop(Name) ->
  Name ! stop.

loop(#state{list = List, counter = Counter} = State) ->
  receive
    {From, add, Key, Value, Comment} when is_pid(From) ->
      io:format("Added element  proc:~p~n", [From]),
      NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
      From ! {ok, NewState#state.counter},
      loop(NewState); %% Рекурсия
    {From, is_member, Key} when is_pid(From) ->
      io:format("Member ~p~n", [From]),
      IsMember =  lists:keymember(Key, 1, List),
      NewState = State#state{counter = Counter + 1},
      From ! {ok, IsMember, NewState#state.counter},
      loop(State);
    {From, take, Key} when is_pid(From) ->
      {Element, NewList} = lists:keytake(Key, 1, List),
      case Element of
        false ->
          From ! {not_found, Counter},
          loop(State);
        {_, Value, Comment} ->
          From ! {ok, {Value, Comment}, Counter + 1},
          NewState = State#state{list = NewList},
          loop(NewState)
      end;
    {From, find, Key} when is_pid(From) ->
      Element = lists:keyfind(Key, 1, List),
      case Element of
        false ->
          From ! {not_found, Counter},
          loop(State);
        {_, Value, Comment} ->
          From ! {ok, {Value, Comment}, Counter + 1},
          loop(State)
      end;
    {From, delete, Key} when is_pid(From) ->
      io:format("Remoted element key:~p  proc ~p ~n", [Key, From]),
      NewList = lists:keydelete(Key, 1, List),
      NewState = State#state{list = NewList, counter = Counter + 1},
      From ! {ok, NewState#state.counter},
      loop(NewState);
    stop ->
      io:format("Terminating in state ~p... ~n", [State]),
      ok;
    {'EXIT', Pid, Reason} ->
      io:format("Linked Process failed ~p with reason ~p~n", [Pid, Reason]),
      loop(State)
  end.


