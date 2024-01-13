%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% The module is used to perform operations of
%%% adding/removing/searching elements with some information.
%%% @end
%%%-------------------------------------------------------------------
-module(keylist_mgr).
-author("r0xyz").
-include_lib("keylist.hrl").

-behavior(gen_server).

-define(TABLE_NAME, keylist_ets).
-define(SERVER, ?MODULE).

%% API
-export([start_link/0, stop/0]).
-export([start_child/1, stop_child/1]).
-export([get_names/0]).

%% Callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).

-record(state,{
  children = []   ::[{atom(), pid()}]
}).

%% API
%% @doc Starts keylist_mgr process
-spec(start_link() -> {ok, pid()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% @doc Stop keylist_mgr process
-spec(stop() -> ok).
stop() ->
  gen_server:cast(?SERVER, stop),
  ok.

%% @doc Starts child keylist_srv process
-spec(start_child(Name :: atom()) -> {ok, pid()}).
start_child(Name) ->
  gen_server:call(?SERVER, {start_child, Name}).

%% @doc Stop child keylist_srv process
-spec(stop_child(Name::atom()) -> ok).
stop_child(Name) ->
  gen_server:call(?SERVER, {stop_child, Name}).

%% @doc Getting a state
-spec(get_names() -> ok).
get_names() ->
  gen_server:call(?SERVER, get_names).

%% Callbacks
init([]) ->
  process_flag(trap_exit, true),
  Tid = ets:new(?TABLE_NAME, [named_table, duplicate_bag, public, {keypos, #keylist_rec.key}]),
  io:format("Init Mgr was called ~n"),
  io:format("Table ETS ~p created ~n", [Tid]),
  {ok, #state{}}.

handle_call({start_child, Name}, _From, State) ->
  keylist_sup:start_child(Name),
  {reply, ok, State};

handle_call({stop_child, Name}, _From, State) ->
  keylist_sup:stop_child(Name),
  {reply, ok, State};

handle_call(get_names, _From, State) ->
  {reply, {ok, State}, State}.

handle_cast(stop, State) ->
  {stop, normal, State}.

handle_info({'DOWN', Ref, process, Pid, Reason}, #state{children = Children} = State) ->
  io:format("Process monitoring ~p completed with reason: ~p~n", [Ref, Reason]),
  NewChildren = lists:filter(fun({_Name, P}) -> P /= Pid end, Children),
  {noreply, State#state{children = NewChildren}}.

terminate(Reason, State) ->
  io:format("Proc ~p terminating reason: ~p in state: ~p~n", [self(), Reason, State]),
  ok.
