1. Добавьте в keylist API:

Функцию keylist:match/2, которая фильтрует и возвращает данные согласно заданному паттерну \
-spec match(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.\
Name - это имя процесса keylist\
Pattern - паттерн матчинга для функции ets:match/2.

Функцию keylist:match_object/2, которая фильтрует и возвращает объекты согласно заданному паттерну\
-spec match_object(Name :: atom(), Pattern :: ets:match_pattern()) -> {ok, list()}.\
Name - это имя процесса keylist\
Pattern - паттерн матчинга для функции ets:match_object/2.\

Функцию keylist:select/2, которая фильтрует и возвращает данные согласно заданной функции фильтрации\
-spec select(Name :: atom(), Filter :: fun()) -> {ok, list()}.\
Name - это имя процесса keylist\
Filter - это функция для которой вы в keylist вызовите ets:fun2ms/1.

КОМАНДЫ ДЛЯ ЗАПУСКА И РАБОТЫ С ПРОГРАММОЙ:
```erlang
c(keylist).
c(keylist_mgr).
rr("keylist.erl").
rr("keylist_mgr.erl").
keylist_mgr:start_monitor().
observer:start().
keylist_mgr:start_child(keylist1, permanent).
keylist_mgr:start_child(keylist2, temporary).
keylist:add(keylist2, key1, 5, "Comment1").
keylist:add(keylist2, key2, 4, "Comment2").
keylist:add(keylist2, key3, 4, "Comment3").
keylist:match(keylist2, {keylist_rec,'$1', 4, '$2'}).
keylist:match(keylist2, {keylist_rec,'$2', 5, '$1'}).
keylist:match(keylist2, {keylist_rec, '$1', 4, '_'}).
keylist:match(keylist2, {'_', key1, '$1', '_'}).
keylist:match_object(keylist2, {'_', key1,'_','_'}).
keylist:match_object(keylist2, {'_', '_', 4,'_'}).
keylist:match_object(keylist2, {'_', '_', '_', "Comment2"}).
F1 = fun(#keylist_rec{key = K, value = V, comment = C}) when K == key1 ->[V, C] end.
F2 = fun(#keylist_rec{key = K, value = V, comment = C}) when V /= 5 ->[K, C] end.
F3 = fun(#keylist_rec{key = K, value = V, comment = C}) when C /= "Comment2" ->[K, V] end.
keylist:select(keylist2, F1).
keylist:select(keylist2, F2).
keylist:select(keylist2, F3).


rd(keylist, {key, value, comment}).
dets:open_file(keylist, [{type, duplicate_bag}, {file, "C:/Users/79642/Desktop/Erlang Eltex/eltex-erlang-homework/hw-13/keylist"}]).
dets:insert(keylist, #keylist{key = key1, value = 5, comment = "Comment1"}).
dets:insert(keylist, #keylist{key = key2, value = 6, comment = "Comment2"}).
dets:insert(keylist, #keylist{key = key3, value = 7, comment = "Comment3"}).
dets:match(keylist, '$1').
```

2. Eshell:
   Протестировать функции с различными паттернами
   - keylist:match/2
    ```erlang
    Eshell V14.1 (press Ctrl+G to abort, type help(). for help)
    1> c(keylist).
    {ok,keylist}
    2> c(keylist_mgr).
    {ok,keylist_mgr}
    3> rr("keylist.erl").
    [cmd_count,keylist_rec]
    4> rr("keylist_mgr.erl").
    [keylist_rec,state]
    5> keylist_mgr:start_monitor().
    Monitor Process Init:
    ETS table created, name: keylist_ets
    {ok,{<0.107.0>,#Ref<0.2472484750.482869253.27753>}}
    6> observer:start().
    ok
    7> keylist_mgr:start_child(keylist1, permanent).
    Child Process Init:
    {ok,<0.129.0>}
    8> keylist_mgr:start_child(keylist2, temporary).
    Child Process Init:
    Received added_new_child message. Pid: <0.131.0>, Name: keylist2
    {ok,<0.131.0>}
    9> keylist:add(keylist2, key1, 5, "Comment1").
    Added new element to ETS: {key1,5,"Comment1"}
    {ok,1}
    10> keylist:add(keylist2, key2, 4, "Comment2").
    Added new element to ETS: {key2,4,"Comment2"}
    {ok,2}
    11> keylist:add(keylist2, key3, 4, "Comment3").
    Added new element to ETS: {key3,4,"Comment3"}
    {ok,3}
    12> keylist:match(keylist2, {keylist_rec,'$1', 4, '$2'}).
    {ok,[[key3,"Comment3"],[key2,"Comment2"]]}
    13> keylist:match(keylist2, {keylist_rec,'$2', 5, '$1'}).
    {ok,[["Comment1",key1]]}
    14> keylist:match(keylist2, {keylist_rec, '$1', 4, '_'}).
    {ok,[[key3],[key2]]}
    15> keylist:match(keylist2, {'_', key1, '$1', '_'}).
    {ok,[[5]]}
    ```
   - keylist:match_object/2
   ```erlang
   16> keylist:match_object(keylist2, {'_', key1,'_','_'}).
   {ok,[#keylist_rec{key = key1,value = 5,
   comment = "Comment1"}]}
   17> keylist:match_object(keylist2, {'_', '_', 4,'_'}).
   {ok,[#keylist_rec{key = key3,value = 4,comment = "Comment3"},
   #keylist_rec{key = key2,value = 4,comment = "Comment2"}]}
   18> keylist:match_object(keylist2, {'_', '_', '_', "Comment2"}).
   {ok,[#keylist_rec{key = key2,value = 4,
   comment = "Comment2"}]}
   ```
   Протестировать функцию keylist:select/2 с различными функциями
   ```erlang
   19> F1 = fun(#keylist_rec{key = K, value = V, comment = C}) when K == key1 ->[V, C] end.
   #Fun<erl_eval.42.105768164>
   20> F2 = fun(#keylist_rec{key = K, value = V, comment = C}) when V /= 5 ->[K, C] end.
   #Fun<erl_eval.42.105768164>
   21> F3 = fun(#keylist_rec{key = K, value = V, comment = C}) when C /= "Comment2" ->[K, V] end.
   #Fun<erl_eval.42.105768164>
   22> keylist:select(keylist2, F1).
   {ok,[[5,"Comment1"]]}
   23> keylist:select(keylist2, F2).
   {ok,[[key3,"Comment3"],[key2,"Comment2"]]}
   24> keylist:select(keylist2, F3).
   {ok,[[key3,4],[key1,5]]}
   ```

3. Eshell:
1) Определите рекорд с данными - используем rd/2 (можете взять рекорд из keylist или из первых ДР рекорд person или придумать свой)
  ```erlang
  Eshell V14.1 (press Ctrl+G to abort, type help(). for help)
  1> rd(keylist, {key, value, comment}).
  keylist
  ``` 
2) Откройте таблицу DETS.
  ```erlang
  2> dets:open_file(keylist, [{type, duplicate_bag}, {file, "C:/Users/79642/Desktop/Erlang Eltex/eltex-erlang-homework/hw-13/keylist"}]).
  {ok,keylist}
  ```
3) Вставьте данные и прочитайте данные из таблицы.
  ```erlang
  3> dets:insert(keylist, #keylist{key = key1, value = 5, comment = "Comment1"}).
  ok
  4> dets:insert(keylist, #keylist{key = key2, value = 6, comment = "Comment2"}).
  ok
  5> dets:insert(keylist, #keylist{key = key3, value = 7, comment = "Comment3"}).
  ok
  6> dets:match(keylist, '$1').
  [[#keylist{key = key1,value = 5,comment = "Comment1"}],
  [#keylist{key = key2,value = 6,comment = "Comment2"}],
  [#keylist{key = key3,value = 7,comment = "Comment3"}]]
  ```
4) Закройте таблицу.
  ```erlang
  8> dets:close(keylist).
  ok
  ```
5) Попробуйте прочитать данные еще раз. Получилось ли?
  ```erlang
  10> dets:match(keylist, '$1').
  ** exception error: bad argument
    in function  dets:match/2
      called as dets:match(keylist,'$1')
  ```
Так как мы закрыли таблицу, не имеем доступа к ее содежимому.
6) Откройте таблицу DETS еще раз.
  ```erlang
  12> dets:open_file(keylist).
  {ok,#Ref<0.3470537973.671350791.177286>}
  ```
7) Завершите ваш Eshell процесс аварийно exit(self()).
  ```erlang
  13> exit(self()).
  ** exception exit: <0.101.0>
  ```
8) Попробуйте прочитать данные еще раз. Получилось ли?
  ```erlang
  14> dets:match(keylist, '$1').
  ** exception error: bad argument
  in function  dets:match/2
  called as dets:match(keylist,'$1')
  ```
После повторного открытия создалась ссылка на DETS, которая стала недоступна после аварийного завершения текущего процесса Eshell.
Прочтение данных, соответственно тоже теперь стало недоступным.