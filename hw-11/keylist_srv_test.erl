-module(keylist_srv_test).
-author("r0xyz").

-include_lib("eunit/include/eunit.hrl").

-define(KEYLIST_NAME, keylist1).

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
  {ok, Pid} = keylist_srv:start_link(?KEYLIST_NAME),
  #{pid => Pid, name => ?KEYLIST_NAME}.

stop(#{name := Name}) ->
  keylist_srv:stop(Name).

test_keylist_add() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",

  ReturnVal = keylist_srv:add(?KEYLIST_NAME, Key, Value, Comment),
  FoundVal = keylist_srv:find(?KEYLIST_NAME, Key),
  [
    ?assertEqual({ok, 1}, ReturnVal),
    ?assertMatch({ok, {Key, Value, Comment}, 2}, FoundVal)
  ].

test_keylist_del() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",

  _AddedVal = keylist_srv:add(?KEYLIST_NAME, Key, Value, Comment),
  FoundValBefore = keylist_srv:find(?KEYLIST_NAME, Key),
  DelVal = keylist_srv:delete(?KEYLIST_NAME, Key),
  FoundValAfter = keylist_srv:find(?KEYLIST_NAME, Key),
  [
    ?assertMatch({ok, {Key, Value, Comment}, 2}, FoundValBefore),
    ?assertEqual({ok, 3}, DelVal),
    ?assertMatch(no_find, FoundValAfter)
  ].

test_keylist_member() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",

  InvalidKey = key2,
  _AddedVal = keylist_srv:add(?KEYLIST_NAME, Key, Value, Comment),
  ValidMember = keylist_srv:is_member(?KEYLIST_NAME, Key),
  InvalidMember = keylist_srv:is_member(?KEYLIST_NAME, InvalidKey),
  [
    ?assertMatch({true, 2}, ValidMember),
    ?assertMatch({false, 3}, InvalidMember)
  ].

test_keylist_take() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",
  NotFoundKey = not_found,

  _AddedVal = keylist_srv:add(?KEYLIST_NAME, Key, Value, Comment),
  ReturnElement = keylist_srv:take(?KEYLIST_NAME, Key),
  NotFoundElement = keylist_srv:find(?KEYLIST_NAME, NotFoundKey),
  [
    ?assertMatch({ok, {Key, Value, Comment}, 2}, ReturnElement),
    ?assertMatch(no_find, NotFoundElement)
  ].

test_keylist_find() ->
  Key = key1,
  Value = 15,
  Comment = "Comm1",
  NotFoundKey = not_found,

  _AddedVal = keylist_srv:add(?KEYLIST_NAME, Key, Value, Comment),
  FoundVal = keylist_srv:find(?KEYLIST_NAME, Key),
  NotFoundElement = keylist_srv:find(?KEYLIST_NAME, NotFoundKey),
  [
    ?assertMatch({ok, {Key, Value, Comment}, 2}, FoundVal),
    ?assertMatch(no_find, NotFoundElement)
  ].
