%%%-------------------------------------------------------------------
%% @doc webRtp public API
%% @end
%%%-------------------------------------------------------------------

-module(webRtp_app).

-include_lib("kernel/include/logger.hrl").

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  %% Start Mnesia
  webRtp_mnesia:start(),
  %% Start cowboy
  Dispatch = cowboy_router:compile([
    {'_', [
            %% В квадратных скобках необязательный параметр
            {"/abonent/[:number]", abonent_h, []},
            {"/abonents", abonents_h, []},
            {"/call/abonent/[:number]", call_abonent_h, []},
            {"/call/broadcast", broadcast_h, []}
        ]}
    ]),
    Port = 8080,
    {ok, _} =
      cowboy:start_clear(http, [{port, Port}],
                        #{env => #{dispatch => Dispatch}}
                        ),
  ?LOG_NOTICE("webRtp start!"),

   webRtp_sup:start_link().

stop(_State) ->
    ok.
