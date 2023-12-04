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

-behavior(gen_server).

%% API
-export([start_monitor/0, stop/0]).
-export([start_child/2, stop_child/1]).
-export([get_names/0]).

%% Callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).

-record(state,{
  children = []   ::[{atom(), pid()}],
  permanent = []  ::[pid()]
}).

%% API
%% @doc Starts keylist_mgr process
-spec(start_monitor() -> {ok, pid()}).
start_monitor() ->
  gen_server:start_monitor({local, ?MODULE}, ?MODULE, [], []).

%% @doc Stop keylist_mgr process
-spec(stop() -> ok).
stop() ->
  gen_server:cast(?MODULE, stop),
  ok.

%% @doc Starts child keylist_srv process
-spec(start_child(atom(), atom()) -> {ok, pid()}).
start_child(Name, Type) ->
  gen_server:call(?MODULE, {start_child, {Name, Type}}).

%% @doc Stop child keylist_srv process
-spec(stop_child(Name::atom()) -> ok).
stop_child(Name) ->
  gen_server:call(?MODULE, {stop_child, Name}).

%% @doc Getting a state
-spec(get_names() -> ok).
get_names() ->
  gen_server:cast(?MODULE, {get_names}).

%% Callbacks
init([]) ->
  process_flag(trap_exit, true),
  io:format("Monitor Process Init: "),
  {ok, #state{children = [], permanent = []}}.

handle_call({start_child, {Name, Type}},
    _From,
    #state{children = Children, permanent = Permanent} = State) ->
  case proplists:get_value(Name, Children) of
    undefined ->
      {ok, Pid} = keylist_srv:start_link(Name),
      NewPermanent =
        case Type of
          permanent -> [Pid | Permanent];
          temporary -> Permanent
        end,
      NewChildren = Children ++ [{Name, Pid}],
      NewState = State#state{children = NewChildren, permanent = NewPermanent},
      lists:foreach(fun({_, ChildPid}) -> ChildPid ! {added_new_child, Pid, Name} end, Children),
      {reply, {ok, Pid}, NewState};
    Pid when is_pid(Pid) ->
      {reply, {error, {already_started, Name}}, State};
    {Name, _ExistingPid} ->
      {reply, {error, {already_started, Name}}, State}
  end;

handle_call({stop_child, Name},
    _From,
    #state{children = Children, permanent = Permanent} = State) ->
  case proplists:get_value(Name, Children) of
    Pid when is_pid(Pid) ->
      keylist_srv:stop(Name),
      NewState = State#state{children = proplists:delete(Name, Children), permanent = lists:delete(Pid, Permanent)},
      {reply, ok, NewState};
    undefined ->
      {reply, {error, {not_started, Name}}, State}
  end.

handle_cast({get_names}, #state{children = Children, permanent = Permanent} = State) ->
  io:format("Children: ~p, Permanent: ~p~n", [Children, Permanent]),
  {noreply, State};

handle_cast(stop, State) ->
  {stop, normal, State}.

handle_info({'EXIT', FailedPid, Reason}, #state{children = Children, permanent = Permanent} = State) ->
  case lists:keysearch(FailedPid, 2, Children) of
    {value, {Name, _}} ->
      case lists:member(FailedPid, Permanent) of
        true ->
          Msg = io_lib:format("~nProcess ~p failed with reason: ~p~n", [Name, Reason]),
          error_logger:error_msg("~s", [Msg]),
          DelChildren = lists:keydelete(Name, 1, Children),
          DelPermanent = lists:delete(FailedPid, Permanent),
          {ok, NewPid} = keylist_srv:start_link(Name),
          io:format("New Pid permanent process: ~p~n", [NewPid]),
          NewPermanent = [NewPid | DelPermanent],
          NewChildren = [{Name, NewPid} | DelChildren],
          lists:foreach(fun({_, ChildPid}) -> ChildPid ! {added_new_child, NewPid, Name} end, NewChildren),
          {noreply, State#state{children = NewChildren, permanent = NewPermanent}};
        false ->
          Msg = io_lib:format("~nProcess ~p failed with reason: ~p~n", [Name, Reason]),
          error_logger:error_msg("~s", [Msg]),
          NewChildren = lists:keydelete(FailedPid, 2, Children),
          lists:foreach(fun({_, ChildPid}) -> ChildPid ! {added_new_child, FailedPid, Name} end, NewChildren),
          {noreply, State#state{children = NewChildren}}
      end;
    false ->
      {noreply, State}
  end;

handle_info({'DOWN', Ref, process, Pid, Reason},
    #state{children = Children} = State) ->
  io:format("Process monitoring ~p completed with reason: ~p~n", [Ref, Reason]),
  NewChildren = lists:filter(fun({_Name, P}) -> P /= Pid end, Children),
  {noreply, State#state{children = NewChildren}}.

terminate(Reason, State) ->
  io:format("Proc ~p terminating reason: ~p in state: ~p~n", [self(), Reason, State]),
  ok.
