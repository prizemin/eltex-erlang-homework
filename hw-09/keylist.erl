%%%-----------------------------------------------------
%%% @author r0xyz
%%% @doc
%%% The module is used to perform operations of
%%% adding/removing/searching elements with some information.
%%% @end
%%%-----------------------------------------------------
-module(keylist).

%% API
-export([start_monitor/1, start_link/1]).
-export([stop/1]).
-export([add/4, is_member/2, take/2, find/2, delete/2]).

%% Callbacks
-export([init/1]).

-record(state,{
  list = []    ::[{atom(), integer(), string()}],
  counter = 0  ::non_neg_integer()
}).

%% @doc Start monitor on the process
-spec(start_monitor(atom()) -> {ok, pid(), reference()}).
start_monitor(Name) when is_atom(Name) ->
  {Pid, MonitorRef} = spawn_monitor(?MODULE, loop, [#state{}]),
  io:format("Started pid ~p ~n", [Pid]),
  register(Name, Pid),
  {ok, Pid, MonitorRef}.

%% @doc Start link with the process
-spec(start_link(atom()) -> {ok, pid()}).
start_link(Name) when is_atom(Name) ->
  case whereis(?MODULE) of
    undefined ->
      Pid = spawn_link(?MODULE, init, [Name]),
      io:format("Linked pid ~p ~n", [Pid]),
      {ok, Pid};
    Pid when is_pid(Pid) ->
      {error, already_register}
  end.

%% @doc Adds a new tuple element to the #state.list
-spec(add(atom(), atom(), integer(), string()) -> ok).
add(Name, Key, Value, Comment) ->
  Name ! {self(), add, Key, Value, Comment},
  ok.

%% @doc Checks if there is an element with the key Key in the #state.list.
-spec(is_member(atom(), atom()) -> true | false).
is_member(Name, Key) ->
  Name ! {self(), is_member, Key}.

%% @doc Finds and returns an element with the key Key and removes it from the list #state.list.
-spec(take(atom(), atom()) -> ok).
take(Name, Key) ->
  Name ! {self(), take, Key},
  ok.
%% @doc Finds and returns an element with the key Key from the list.
-spec(find(atom(), atom()) -> ok).
find(Name, Key) ->
  Name ! {self(), find, Key},
  ok.
%% @doc Removes an item with the key Key from the #state.list.
-spec(delete(atom(), atom()) -> ok).
delete(Name, Key) ->
  Name ! {self(), delete, Key},
  ok.

%% @doc Stops the process
-spec(stop(atom()) -> ok).
stop(Name) ->
  Name ! stop,
  ok.

init(Name) ->
  process_flag(trap_exit, true),
  register(Name, self()),
  loop(#state{}).

loop(#state{list = List, counter = Counter} = State) ->
  receive
    {From, add, Key, Value, Comment} when is_pid(From) ->
      io:format("Added element  proc:~p~n", [From]),
      NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
      From ! {ok, NewState#state.counter},
      loop(NewState); %% Рекурсия
    {From, is_member, Key} when is_pid(From) ->
      IsMember =  lists:keymember(Key, 1, List),
      io:format("Element with the key ~p exist: ~p~n", [Key, IsMember]),
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
          io:format("Element ~p with the key ~p removed: ~n", [Element, Key]),
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
          io:format("Found element ~p: ~n", [Element]),
          From ! {ok, {Value, Comment}, Counter + 1},
          loop(State)
      end;
    {From, delete, Key} when is_pid(From) ->
      Element = lists:keyfind(Key, 1, List),
      io:format("Remoted element ~p with a key: ~p ~n", [Element, Key]),
      NewList = lists:keydelete(Key, 1, List),
      NewState = State#state{list = NewList, counter = Counter + 1},
      From ! {ok, NewState#state.counter},
      loop(NewState);
    stop ->
      io:format("keylist terminating in state ~p ~n", [State]),
      exit(normal),
      ok;
    {'EXIT', Pid, Reason} ->
      io:format("Linked Process failed ~p with reason ~p~n", [Pid, Reason]),
      loop(State)
  end.



