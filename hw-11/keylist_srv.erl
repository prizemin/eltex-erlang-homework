%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% The module is used to perform operations of
%%% adding/removing/searching elements with some information.
%%% @end
%%%-------------------------------------------------------------------
-module(keylist_srv).
-author("r0xyz").

-behavior(gen_server).

%% API
-export([start_link/1, stop/1]).
-export([add/4, delete/2]).
-export([is_member/2]).
-export([take/2]).
-export([find/2]).

%% Callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_info/2]).
-export([terminate/2]).

-record(state_child,{
  list = []    :: [{atom(), integer(), string()}],
  counter = 0  :: non_neg_integer()
}).

%% API
%% @doc Starts the linked process
-spec(start_link(atom()) -> {ok, pid()}).
start_link(Name) ->
  gen_server:start_link({local, Name}, ?MODULE, [], []).

%% @doc Adds a new tuple element to the #state.list
%%-spec(add(atom(), atom(), integer(), string()) -> {ok, list()}).
add(Name, Key, Value, Comment) ->
  gen_server:call(Name, {add, Key, Value, Comment}).

%% @doc Removes an item with the key Key from the #state.list.
%%-spec(delete(atom(), atom()) -> {ok, record()}).
delete(Name, Key) ->
  gen_server:call(Name, {delete, Key}).

%% @doc Checks if there is an element with the key Key in the #state.list.
-spec(is_member(atom(), atom()) -> {ok, atom(), non_neg_integer()}).
is_member(Name, Key) ->
  gen_server:call(Name, {is_member, Key}).

%% @doc Finds and returns an element with the key Key and removes it from the list #state.list.
-spec(take(atom(), atom()) -> {ok, tuple(), non_neg_integer()}).
take(Name, Key) ->
  gen_server:call(Name, {take, Key}).

%% @doc Finds and returns an element with the key Key from the list.
-spec(find(atom(), atom()) -> {ok, tuple(), non_neg_integer()}).
find(Name, Key) ->
  gen_server:call(Name, {find, Key}).

-spec(stop(atom()) -> ok).
stop(Name) ->
  gen_server:stop(Name),
  ok.

%% Callbacks
init([]) ->
  io:format("Process Init: ~n"),
  {ok, #state_child{}}.

handle_call({add, Key, Value, Comment},
    _From,
    #state_child{list = List, counter = Counter} = State) ->
  io:format("Added new element: ~p~n", [{Key, Value, Comment}]),
%%  timer:sleep(10000),
%%  1/0,
  NewState = State#state_child{list = List ++ [{Key, Value, Comment}], counter = Counter + 1},
  {reply, {ok, NewState#state_child.counter},  NewState};

handle_call({delete, Key},
    _From,
    #state_child{list = List, counter = Counter} = State) ->
  Element = lists:keyfind(Key, 1, List),
  io:format("Remoted element ~p with a key: ~p ~n", [Element, Key]),
  NewList = proplists:delete(Key, List),
  NewState = State#state_child{list = NewList, counter = Counter + 1},
  {reply, {ok, NewState#state_child.counter}, NewState};

handle_call({is_member, Key},
    _From,
    #state_child{list = List, counter = Counter} = State) ->
  IsMember =  lists:keymember(Key, 1, List),
  io:format("Element with the key: ~p exist: ~p~n", [Key, IsMember]),
  NewState = State#state_child{counter = Counter + 1},
  {reply, {IsMember, NewState#state_child.counter}, NewState};

handle_call({take, Key},
    _From,
    #state_child{list = List, counter = Counter} = State) ->
  case lists:keytake(Key, 1, List) of
    false ->
      {reply, {no_find}, State};
    {value, Element, NewList} ->
      io:format("New List: ~p~n", [NewList]),
      io:format("Element ~p with the key: ~p removed ~n", [Element, Key]),
      NewState = State#state_child{list = NewList, counter = Counter + 1},
      {reply, {ok, Element, NewState#state_child.counter}, NewState}
  end;

handle_call({find, Key},
    _From,
    #state_child{list = List, counter = Counter} = State) ->
  case lists:keyfind(Key, 1, List) of
    false ->
      {reply, no_find, State};
    {Key, _Value, _Comment} = Element ->
      io:format("Found element: ~p ~n", [Element]),
      NewState = State#state_child{counter = Counter + 1},
      {reply, {ok, Element, NewState#state_child.counter}, NewState}
  end.

handle_info({added_new_child, NewPid, NewName}, State) ->
  io:format("Received added_new_child message. Pid: ~p, Name: ~p~n", [NewPid, NewName]),
  {noreply, State}.

terminate(Reason, State) ->
  io:format("Proc ~p terminating reason: ~p in state: ~p~n", [self(), Reason, State]),
  ok.