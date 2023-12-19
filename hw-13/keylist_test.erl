-module(keylist_test).
-author("r0xyz").

-include_lib("eunit/include/eunit.hrl").
-include("keylist.hrl").

-define(KEYLIST_NAME, keylist1).
-define(TABLE_NAME, keylist_ets).

keylist_test_() ->
  {
    foreach, fun start/0, fun stop/1,
    [
      fun test_keylist_add/0,
      fun test_keylist_del/0,
      fun test_keylist_member/0,
      fun test_keylist_take/0,
      fun test_keylist_find/0
    ]
  }.

start() ->
  ets:new(?TABLE_NAME, [named_table, duplicate_bag, public, {keypos, 2}]),
  {ok, Pid} = keylist:start_link(?KEYLIST_NAME),
  #{pid => Pid, name => ?KEYLIST_NAME}.

stop(#{name := Name}) ->
  keylist:stop(Name).

test_keylist_add() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",

  Record = #keylist_rec{key = Key, value = Value, comment = Comment},
  ?debugFmt("Record: ~p~n", [Record]),
  ReturnVal = keylist:add(?KEYLIST_NAME, Key, Value, Comment),
  FoundVal = keylist:find(?KEYLIST_NAME, Key),
  ?debugFmt("FoundVal: ~p~n", [FoundVal]),
  [
    ?assertEqual({ok, 1}, ReturnVal),
    ?assertMatch({ok, [Record], 2}, FoundVal)
  ].

test_keylist_del() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",

  Record = #keylist_rec{key = Key, value = Value, comment = Comment},

  _AddedVal = keylist:add(?KEYLIST_NAME, Key, Value, Comment),
  FoundValBefore = keylist:find(?KEYLIST_NAME, Key),
  DelVal = keylist:delete(?KEYLIST_NAME, Key),
  FoundValAfter = keylist:find(?KEYLIST_NAME, Key),
  [
    ?assertMatch({ok, [Record], 2}, FoundValBefore),
    ?assertEqual({ok, 3}, DelVal),
    ?assertMatch(not_found, FoundValAfter)
  ].

test_keylist_member() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",

  InvalidKey = key2,
  _AddedVal = keylist:add(?KEYLIST_NAME, Key, Value, Comment),
  ValidMember = keylist:is_member(?KEYLIST_NAME, Key),
  InvalidMember = keylist:is_member(?KEYLIST_NAME, InvalidKey),
  [
    ?assertMatch({true, 2}, ValidMember),
    ?assertMatch(false, InvalidMember)
  ].

test_keylist_take() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",
  NotFoundKey = not_found,

  Record = #keylist_rec{key = Key, value = Value, comment = Comment},

  _AddedVal = keylist:add(?KEYLIST_NAME, Key, Value, Comment),
  ReturnElement = keylist:take(?KEYLIST_NAME, Key),
  NotFoundElement = keylist:find(?KEYLIST_NAME, NotFoundKey),
  [
    ?assertMatch({ok, [Record], 2}, ReturnElement),
    ?assertMatch(false, NotFoundElement)
  ].

test_keylist_find() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",
  NotFoundKey = not_found,

  Record = #keylist_rec{key = Key, value = Value, comment = Comment},

  _AddedVal = keylist:add(?KEYLIST_NAME, Key, Value, Comment),
  FoundVal = keylist:find(?KEYLIST_NAME, Key),
  NotFoundElement = keylist:find(?KEYLIST_NAME, NotFoundKey),
  [
    ?assertMatch({ok, [Record], 2}, FoundVal),
    ?assertMatch(not_found, NotFoundElement)
  ].
