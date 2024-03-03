%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%% Модуль реализует обработку запроса с методом GET для вывода инфомрации
%%% обо всех абонентах используя API webRtp_mnesia
%%% @end
%%%-------------------------------------------------------------------
-module(abonents_h).
-author("r0xyz").

-behavior(cowboy_handler).

-export([init/2]).

init(Request, State) ->
  Method = cowboy_req:method(Request),
  handle_req(Method, Request),

  {ok, Request, State}.

handle_req(<<"GET">>, Req) ->
  AbonentsList = webRtp_mnesia:get_all_abonents(),
  case AbonentsList of
    not_found ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - There are no abonents!", Req);
    _ ->
      AbonentsData = lists:map(fun({_TableName, Num, Name}) -> #{<<"num">> => Num, <<"name">> => Name} end, AbonentsList),
      EncodedResponse = jsone:encode(AbonentsData),
      cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, EncodedResponse, Req)
  end.