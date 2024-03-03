%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%% Модуль реализует обработку запросов с методами: POST, DELETE, GET,
%%% связанных с добавлением/удалением/возвращением конкретного абонента относительно БД.
%%% @end
%%%-------------------------------------------------------------------
-module(abonent_h).
-author("r0xyz").

%%-include_lib("nksip/include/nksip.hrl").

-behavior(cowboy_handler).

-export([init/2]).

init(Request, State) ->
  Method = cowboy_req:method(Request),
  handle_req(Method, Request),

  {ok, Request, State}.

handle_req(<<"POST">>, Req) ->
  case cowboy_req:has_body(Req) of
    true ->
      {ok, ReqBody, Req2} = cowboy_req:read_body(Req),
      JsonData = jsone:decode(ReqBody),
      Num = maps:get(<<"num">>, JsonData),
      Name = maps:get(<<"name">>, JsonData),
      %% По хорошему, еще нужна проверка на корректность тела.
      case webRtp_mnesia:get_abonent(Num) of
        not_found ->
          webRtp_mnesia:insert_abonent(Num, Name),
          cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent successfully added!", Req2);
        _ ->
          cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent is already!", Req)
      end;
    false ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - No Body Request!", Req)
  end;
handle_req(<<"GET">>, Req) ->
  NumberBin = cowboy_req:binding(number, Req),
  Number = binary_to_integer(NumberBin),
  Abonent = webRtp_mnesia:get_abonent(Number),
  case Abonent of
    {Num, Name} ->
      AbonentData = #{<<"num">> => Num, <<"name">> => Name},
      EncodedResponse = jsone:encode(AbonentData),
      cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, EncodedResponse, Req);
    not_found ->
      cowboy_req:reply(400, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent not found!", Req)
  end;
handle_req(<<"DELETE">>, Req) ->
  NumberBin = cowboy_req:binding(number, Req),
  Number = binary_to_integer(NumberBin),
  Result = webRtp_mnesia:delete_abonent(Number),
  case Result of
    ok ->
      cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, "Abonent deleted successfully!", Req);
    {error, not_found} ->
      cowboy_req:reply(404, #{<<"content-type">> => <<"text/plain">>}, "Error - Abonent not found!", Req)
  end.

