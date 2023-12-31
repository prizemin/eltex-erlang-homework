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
-export([match/2, match_object/2, select/2]).

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
-spec(add(atom(), atom(), integer(), string()) -> {ok, non_neg_integer()}).
add(Name, Key, Value, Comment) ->
  gen_server:call(Name, {add, Key, Value, Comment}).

%% @doc Removes an item with the key Key from the ETS.
-spec(delete(Name :: atom(), Key :: atom()) -> {ok, non_neg_integer()}).
delete(Name, Key) ->
  gen_server:call(Name, {delete, Key}).

%% @doc Checks if there is an element with the key Key in the ETS.
-spec(is_member(Name :: atom(), Key :: atom()) -> {ok, boolean()}).
is_member(Name, Key) ->
  gen_server:call(Name, {is_member, Key}).

%% @doc Finds and returns an element with the key Key and removes it from the list #state.list.
-spec(take(Name :: atom(), Key :: atom()) -> {ok, list()}).
take(Name, Key) ->
  gen_server:call(Name, {take, Key}).

%% @doc Finds and returns an element with the key Key from the list.
-spec(find(Name :: atom(), Key :: atom()) -> {ok, list()}).
find(Name, Key) ->
  gen_server:call(Name, {find, Key}).

%% @doc Filters and returns data according to the specified pattern.
-spec match(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.
match(Name, Pattern) ->
  gen_server:call(Name, {match, Pattern}).

%% @doc Filters and returns objects according to the specified pattern.
-spec match_object(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.
match_object(Name, Pattern) ->
  gen_server:call(Name, {match_object, Pattern}).

%% @doc Filters and returns data according to the specified filtering function.
-spec select(Name :: atom(), Filter :: fun()) -> {ok, list()}.
select(Name,Filter) ->
  gen_server:call(Name, {select, Filter}).

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
      {reply, true, NewState};
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
      {reply, {ok, Element}, NewState}
  end;

handle_call({find, Key}, _From, #cmd_count{counter = Counter} = State) ->
  case ets:lookup(?TABLE_NAME, Key) of
    [] ->
      io:format("Element with the key ~p was not found~n", [Key]),
      {reply, not_found, State};
    Element ->
      NewState = State#cmd_count{counter = Counter + 1},
      {reply, {ok, Element}, NewState}
  end;

handle_call({match, Pattern}, _From, #cmd_count{counter = Counter} = State) ->
  MatchResult = ets:match(?TABLE_NAME, Pattern),
  NewState = State#cmd_count{counter = Counter + 1},
  {reply, {ok, MatchResult}, NewState};

handle_call({match_object, Pattern}, _From, #cmd_count{counter = Counter} = State) ->
  MatchResult = ets:match_object(?TABLE_NAME, Pattern),
  NewState = State#cmd_count{counter = Counter + 1},
  {reply, {ok, MatchResult}, NewState};

handle_call({select, Filter}, _From, #cmd_count{counter = Counter} = State) ->
  MS = ets:fun2ms(Filter),
  MatchResult = ets:select(?TABLE_NAME, MS),
  NewState = State#cmd_count{counter = Counter + 1},
  {reply, {ok, MatchResult}, NewState}.

handle_info({added_new_child, NewPid, NewName}, State) ->
  io:format("Received added_new_child message. Pid: ~p, Name: ~p~n", [NewPid, NewName]),
  {noreply, State}.

terminate(Reason, State) ->
  io:format("Proc ~p terminating reason: ~p in state: ~p~n", [self(), Reason, State]),
  ok.