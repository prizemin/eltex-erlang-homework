%%%-----------------------------------------------------
%%% @author r0xyz
%%% @doc
%%% The module is used to start and stop child processes,
%%% as well as to get information about them
%%% @end
%%%-----------------------------------------------------
-module(keylist_mgr).

%% API
-export([start/0, stop/1]).
-export([start_child/1, stop_child/1]).
-export([get_names/0]).
%% Callbacks
%% @hidden
-export([init/0]).
%% @hidden

-record(state,{
  children = []   ::[{atom(), pid()}],
  permanent = []  ::[pid()]
}).

%% @doc Starts keylist_mgr process
-spec(start() -> {ok, pid(), reference()}).
start() ->
  case whereis(?MODULE) of
    undefined ->
      {Pid, MonitorRef} = spawn_monitor(?MODULE, init, []),
      io:format("Started pid ~p ~n", [Pid]),
      {ok, Pid, MonitorRef};
    Pid when is_pid(Pid) ->
      {error, already_register}
  end.

%% @doc Starts child keylist process
-spec(start_child(Params::map()) -> ok).
start_child(Params) when is_map(Params) ->
  ?MODULE ! {self(), start_child, Params},
  ok.

%% @doc Stop child keylist process
-spec(stop_child(Name::atom()) -> ok).
stop_child(Name) when is_atom(Name) ->
  ?MODULE ! {self(), stop_child, Name},
  ok.

%% @doc Stop keylist_mgr process
-spec(stop(Name::atom()) -> ok).
stop(Name) when is_atom(Name) ->
  Name ! stop,
  ok.
%% @doc Getting a list of Pids
-spec(get_names() -> #state{}).
get_names() ->
  ?MODULE ! {self(), get_names}.

init() ->
  register(?MODULE , self()),
  process_flag(trap_exit, true),
  loop(#state{}).

loop(#state{children = Children, permanent = Permanent} = State) ->
  receive
    {From, start_child, Params} when is_map(Params)->
      Name = maps:get(name, Params),
      Type = maps:get(restart, Params),
      case proplists:get_value(Name, Children) of
        undefined ->
          {ok, Pid} = keylist:start_link(Name),
          NewPermanent =
            case Type of
              permanent -> [Pid | Permanent];
              temporary -> Permanent
            end,
          NewChildren = [{Name, Pid} | Children],
          From ! {ok, Pid},
          loop(State#state{children = NewChildren, permanent = NewPermanent});
        Pid when is_pid(Pid) ->
          From ! {error, "Process with the same name already exists"},
          loop(State)
      end;

    {From, stop_child, Name} ->
      case proplists:get_value(Name, Children) of
        Pid when is_pid(Pid) ->
          keylist:stop(Name),
          NewState = State#state{children = proplists:delete(Name, Children)},
          From ! {ok, NewState},
          loop(NewState);
        undefined ->
          io:format("Process with name ~p undefined ~n", [Name]),
          From ! {error, not_started},
          loop(State)
      end;

    {From, get_names} ->
      io:format("Children: ~p~n", [State]),
      From ! State,
      loop(State);

    {'EXIT', FailedPid, Reason} ->
      {Name, _} = lists:keyfind(FailedPid, 2, Children),
      case lists:member(FailedPid, Permanent) of
        true ->
          Msg = io_lib:format("~nProcess ~p failed with reason: ~p~n", [Name, Reason]),
          error_logger:error_msg("~s", [Msg]),
          %%io:format("Process ~p failed with reason: ~p", [FailedPid, Reason]),
          DelChildren = lists:keydelete(Name, 1, Children),
          DelPermanent = lists:delete(FailedPid, Permanent),
          {ok, NewPid} = keylist:start_link(Name),
          NewPermanent = [NewPid | DelPermanent],
          NewChildren = [{Name, NewPid} | DelChildren],
          loop(State#state{children = NewChildren, permanent = NewPermanent});
        false ->
          Msg = io_lib:format("~nProcess ~p failed with reason: ~p~n", [Name, Reason]),
          error_logger:error_msg("~s", [Msg]),
          %%io:format("Process ~p failed with reasonnnn: ~p", [FailedPid, Reason]),
          NewChildren = lists:keydelete(Name, 1, Children),
          loop(State#state{children = NewChildren})
      end;

    {'DOWN', Ref, process, Pid, Reason} ->
      io:format("Process monitoring ~p completed with reason: ~p~n", [Ref, Reason]),
      NewChildren = lists:filter(fun({_Name, P}) -> P /= Pid end, Children),
      loop(State#state{children = NewChildren});

    stop ->
      terminate(State),
      ok
  end.

terminate(#state{children = Children} = State) ->
  lists:foreach(
    fun({_Name, Pid}) ->
      keylist:stop(Pid)
    end,
    Children),
  io:format("Terminating in state ~p... ~n", [State]).

