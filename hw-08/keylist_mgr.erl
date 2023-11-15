-module(keylist_mgr).

%% API
-export([start/0]).
%% Callbacks
%% @hidden
-export([init/0]).
%% @hidden

-record(state,{
  children = []
}).

start() ->
  {Pid, MonitorRef} = spawn_monitor(?MODULE, init, []),
  io:format("Started pid ~p ~n", [Pid]),
  {ok, Pid, MonitorRef}.

init() ->
  io:format("Init ~p~n", [self()]),
  register(?MODULE , self()),
  loop(#state{}).

loop(#state{children = Children} = State) ->
  process_flag(trap_exit, true),
  receive
    {From, start_child, Name} ->
      case proplists:get_value(Name, Children) of
        undefined ->
          {ok, Pid} = keylist:start_link(Name),
          NewChildren = [{Name,Pid} | Children],
          From ! {ok, Pid},
          loop(State#state{children = NewChildren});
        {_, Pid} when is_pid(Pid) ->
          From ! {error, "Process with the same name already exists"},
          loop(State)
      end;

    {From, stop_child, Name} ->
      case proplists:get_value(Name, Children) of
        {_, Pid} when is_pid(Pid) ->
          keylist:stop(Name),
          NewState = State#state{children = proplists:delete(Name, Children)},
          From ! {ok, NewState},
          loop(NewState);
        undefined ->
          io:format("Process with name ~p undefined ~n", [Name]),
          From ! {error, not_started}
      end;

    stop ->
      io:format("Terminating in state ~p... ~n", [State]),
      ok;

    {From, get_names} ->
      io:format("Children: ~p~n", [State]),
      From ! State,
      loop(State);

    {'EXIT', Pid, Reason} ->
      NewChildren = lists:keydelete(Pid, 2, Children),
      error_logger:error_msg("Process ~p failed with reason ~p~n: ~p", [Pid, Reason]),
      loop(State#state{children = NewChildren});
    {'DOWN', Ref, process, Pid, Reason} ->
      io:format("Процесс упал по причине: ~p~n", [Reason])
  end.
