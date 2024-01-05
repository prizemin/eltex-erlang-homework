%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. янв. 2024 11:56
%%%-------------------------------------------------------------------
-module(sup).
-author("r0xyz").

-behavior(supervisor).

%% API
-export([start_link/0]).
%% Callback
-export([init/1]).

-define(SERVER, ?MODULE).

%% API

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init(_Args) ->
  io:format("Init SUPERVISOR was called ~n"),

  SupFlags = #{
    strategy => one_for_all,
    intensity => 1,
    period => 5
  },

  MgrSpecs =
    #{id => keylist_mgr,
      start => {keylist_mgr, start_link, []},
      restart => permanent,
      type => worker
    },
  KeylistSupSpecs = #{
      id => keylist_sup,
      start => {keylist_sup, start_link, []},
      restart => permanent,
      type => supervisor
    },

  ChildSpecs = [MgrSpecs, KeylistSupSpecs],
  {ok, {SupFlags, ChildSpecs}}.
