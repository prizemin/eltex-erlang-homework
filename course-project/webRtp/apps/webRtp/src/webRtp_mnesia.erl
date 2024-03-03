%%%-------------------------------------------------------------------
%%% @author r0xyz
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%% Модуль реализует API стандартных операций для работы с БД.
%%% *Используется чистое чтение с использованием транзакций
%%% @end
%%%-------------------------------------------------------------------
-module(webRtp_mnesia).
-author("r0xyz").

-include_lib("kernel/include/logger.hrl").

%% API
-export([start/0, stop/0]).
-export([insert_abonent/2, delete_abonent/1]).
-export([get_abonent/1, get_all_abonents/0]).

-record(abonent, {
  num  :: non_neg_integer(),
  name :: string()
}).
%% API
%% @doc Инициализация БД.
-spec start() -> {ok, ok} | {error, term()}.
start() ->
  mnesia:start(),
  init_schema(),
  create_abonent_table().

%% @doc Остановка БД.
-spec stop() -> ok.
stop() ->
  mnesia:stop(),
  ok.

create_abonent_table() ->
  %% Default: set / ram_copies
  case mnesia:create_table(abonent, [{attributes, record_info(fields, abonent)}]) of
    {atomic, ok} ->
      ?LOG_NOTICE("Table was created successfully!"),
      ok;
    {aborted, {error, already_exists}} ->
      ?LOG_WARNING("Table has already been created."),
      ok;
    {aborted, Reason} ->
      {error, Reason}
  end.

%% @doc Добавление абонента в таблицу.
-spec insert_abonent(Num :: non_neg_integer(), Name ::string()) ->
                    {atomic, ok} | {error, term()}.
insert_abonent(Num, Name) ->
  AbonentRec = #abonent{num = Num, name = Name},
  Trans =
    fun() ->
      case mnesia:read(abonent, Num) of
        [] ->
          mnesia:write(AbonentRec),
          ?LOG_NOTICE("Abonent ~p successfully added in the table!", [Num]);
        [_] ->
          ?LOG_WARNING("Abonent ~p is already in the table.", [Num]),
          {error, already_exists}
      end
    end,
  {atomic, Res} = mnesia:transaction(Trans),
  Res.

%% @doc Удаление абонента из таблицы.
-spec delete_abonent(Num :: non_neg_integer()) ->
                    {atomic, ok} | {error, term()}.
delete_abonent(Num) ->
  Trans =
    fun() ->
      case mnesia:read(abonent, Num) of
        [_] ->
          mnesia:delete({abonent, Num}),
          ?LOG_NOTICE("Abonent ~p has been successfully deleted!", [Num]);
        [] ->
          ?LOG_WARNING("Abonent ~p is not in the table!", [Num]),
          {error, not_found}
      end
    end,

  {atomic, Res} = mnesia:transaction(Trans),
  Res.

%% @doc Получение информации об абоненте.
-spec get_abonent(Num :: non_neg_integer()) ->
                 {atomic, {non_neg_integer(), string()} | not_found}.
get_abonent(Num) ->
  Trans = fun() ->
    case mnesia:read({abonent, Num}) of
      [{abonent, Num, Name}] ->
        {Num, Name};
      [] ->
        not_found
    end
          end,
  {atomic, Res} = mnesia:transaction(Trans),
  Res.
%% @doc Получение списка всех абонентов.
-spec get_all_abonents() ->
        {atomic, [{non_neg_integer(), string()}] | not_found}.
get_all_abonents() ->
  {atomic, Result} =
    mnesia:transaction(
      fun() ->
        mnesia:select(abonent, [{'_', [], ['$_']}])
      end
    ),
  case Result of
    [] ->
      ?LOG_WARNING("No abonents found in table!"),
      not_found;
    _ ->
      Result
  end.

%% Callback
init_schema() ->
  case mnesia:create_schema([node()]) of
    {ok, _} ->
      ok;
    {error, {already_exists, _}} ->
      ok;
    {error, Reason} ->
      {error, Reason}
  end.