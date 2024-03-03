%%%-------------------------------------------------------------------
%% @doc webRtp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(webRtp_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  SupFlags = #{strategy => one_for_one,
    intensity => 10,
    period => 60},
  ChildsSpec = [ %% Start nksip
                #{id => webrtp_nksip,
                  start => {webRtp_nksip, start, []},
                  restart => permanent
                }
  ],
  supervisor:start_link({local, ?MODULE}, ?MODULE, {SupFlags, ChildsSpec}).

init(ChildSpecs) ->
  {ok, ChildSpecs}.

%% internal functions
