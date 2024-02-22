%%%-------------------------------------------------------------------
%% @doc webRtp public API
%% @end
%%%-------------------------------------------------------------------

-module(webRtp_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("Application start!"),
    webRtp_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
