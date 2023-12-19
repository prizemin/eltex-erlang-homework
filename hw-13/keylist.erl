%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% The module is used to perform operations of
%%% adding/removing/searching elements with some information.
%%% @end
%%%-------------------------------------------------------------------
-module(keylist).
-author("r0xyz").
-include_lib("keylist.hrl").

-behavior(gen_server).

-define(TABLE_NAME, keylist_ets).

%% API
-export([start_link/1, stop/1]).
-export([add/4, delete/2]).
-export([is_member/2, take/2, find/2]).

%% Callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_info/2]).
-export([terminate/2]).

-record(cmd_count,{
  counter = 0  :: non_neg_integer()
}).

%% API
%% @doc Starts the linked process
-spec(start_link(atom()) -> {ok, pid()}).
start_link(Name) ->
  gen_server:start_link({local, Name}, ?MODULE, [], []).

%% @doc Adds a new record-element to the ETS table
-spec(add(atom(), atom(), integer(), string()) -> {ok, list()}).
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

%% @doc Stop keylist process.
-spec(stop(atom()) -> ok).
stop(Name) ->
  gen_server:stop(Name),
  ok.

%% Callbacks
init([]) ->
  io:format("Child Process Init: ~n"),
  {ok, #cmd_count{}}.

handle_call({add, Key, Value, Comment}, _From, #cmd_count{counter = Counter} = State) ->
  Record = #keylist_rec{key = Key, value = Value, comment = Comment},
  ets:insert(?TABLE_NAME, Record),
  io:format("Added new element to ETS: ~p~n", [{Key, Value, Comment}]),
  NewState = State#cmd_count{counter = Counter + 1},
  {reply, {ok, NewState#cmd_count.counter},  NewState};

handle_call({delete, Key}, _From, #cmd_count{counter = Counter} = State) ->
  case ets:lookup(?TABLE_NAME, Key) of
    [] ->
      io:format("Element with the key ~p doesn`t exist in ETS~n", [Key]),
      {reply, false, State};
    _Element ->
      ets:delete(?TABLE_NAME, Key),
      io:format("Element(s) with key ~p has been removed from ETS~n", [Key]),
      NewState = State#cmd_count{counter = Counter + 1},
      {reply, {ok, NewState#cmd_count.counter}, NewState}
  end;

handle_call({is_member, Key}, _From, #cmd_count{counter = Counter} = State) ->
  case ets:member(?TABLE_NAME, Key) of
    true ->
      io:format("Element(s) with the key: ~p exist in ETS:~n", [Key]),
      NewState = State#cmd_count{counter = Counter + 1},
      {reply, NewState#cmd_count.counter, NewState};
    false ->
      io:format("Element with the key ~p doesn`t exist in ETS~n", [Key]),
      {reply, false, State}
  end;

handle_call({take, Key}, _From, #cmd_count{counter = Counter} = State) ->
  case ets:lookup(?TABLE_NAME, Key) of
    [] ->
      io:format("Element with the key ~p doesn`t exist in ETS~n", [Key]),
      {reply, false, State};
    Element ->
      io:format("Element(s) with key ~p has been removed from ETS~n", [Key]),
      NewState = State#cmd_count{counter = Counter + 1},
      {reply, {ok, Element, NewState#cmd_count.counter}, NewState}
  end;

handle_call({find, Key}, _From, #cmd_count{counter = Counter} = State) ->
  case ets:lookup(?TABLE_NAME, Key) of
    [] ->
      io:format("Element with the key ~p was not found~n", [Key]),
      {reply, not_found, State};
    Element ->
      NewState = State#cmd_count{counter = Counter + 1},
      {reply, {ok, Element, NewState#cmd_count.counter}, NewState}
  end.

handle_info({added_new_child, NewPid, NewName}, State) ->
  io:format("Received added_new_child message. Pid: ~p, Name: ~p~n", [NewPid, NewName]),
  {noreply, State}.

terminate(Reason, State) ->
  io:format("Proc ~p terminating reason: ~p in state: ~p~n", [self(), Reason, State]),
  ok.