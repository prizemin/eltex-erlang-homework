%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%% Модуль реализует обзвон всех абонентов, находящихся в БД через запрос GET,
%%% используя API из модулей webRtp_mnesia и webRtp_nksip
%%% и выводит его результаты
%%% @end
%%%-------------------------------------------------------------------
-module(broadcast_h).
-author("r0xyz").

-behavior(cowboy_handler).

-export([init/2]).

init(Request, State) ->
  Method = cowboy_req:method(Request),
  handle_req(Method, Request),
  {ok, Request, State}.

handle_req(<<"GET">>, Req) ->
  AbonentsList = webRtp_mnesia:get_all_abonents(),
  ResultsCallList = [{Number, call(Number)} || {_, Number, _} <- AbonentsList],
  ResponseBody = io_lib:format("Call Results: ~p", [ResultsCallList]),
  cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, lists:flatten(ResponseBody), Req).

call(AbonentNumber) ->
  case webRtp_nksip:register(AbonentNumber) of
    {ok, registred} ->
      webRtp_nksip:call_abonent(AbonentNumber);
    _ ->
      {error, not_registred}
  end.


