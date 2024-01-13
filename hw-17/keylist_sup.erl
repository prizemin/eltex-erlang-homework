%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. янв. 2024 11:56
%%%-------------------------------------------------------------------
-module(keylist_sup).
-author("r0xyz").

-define(SERVER, ?MODULE).

-behavior(supervisor).

%% API
-export([start_link/0, start_child/1, stop_child/1]).
%% Callback
-export([init/1]).

%% API

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child(Name) when is_atom(Name) ->
  supervisor:start_child(?SERVER, [Name]).

stop_child(Name) when is_atom(Name) ->
  supervisor:terminate_child(?SERVER, whereis(Name)).

init(_Args) ->
  io:format("Init keylist_sup was called ~n"),
  SupFlags = #{
    strategy => simple_one_for_one,
    intensity => 1,
    period => 5
  },

  ChildSpecs  = [
    #{
      id => keylist,
      start => {keylist, start_link, []},
      restart => permanent,
      type => worker
    }
  ],

  {ok, {SupFlags, ChildSpecs}}.