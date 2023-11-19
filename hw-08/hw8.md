*Eshell:*\
*Проверьте ваш pid (self/0).*\
*Создайте keylist_mgr:*\
*keylist_mgr:start().*\
*Создайте 3 процесса keylist1, keylist2, keylist3*\
*keylist_mgr ! {self(), start_child, keylist1}.*
```erlang
1> c(keylist).
{ok,keylist}
2> rr("keylist.erl").
[state]
3> c(keylist_mgr).
{ok,keylist_mgr}
4> self().
<0.85.0>
5> {_, PidMgr, _} = keylist_mgr:start().
Started pid <0.100.0>
Init <0.100.0>
{ok,<0.100.0>,#Ref<0.2462960795.967311363.29817>}
6> PidMgr ! {self(), start_child, keylist1}.
Linked pid <0.102.0>
{<0.85.0>,start_child,keylist1}
7> PidMgr ! {self(), start_child, keylist2}.
Linked pid <0.104.0>
{<0.85.0>,start_child,keylist2}
8> PidMgr ! {self(), start_child, keylist3}.
Linked pid <0.106.0>
{<0.85.0>,start_child,keylist3}
```
*Отправьте сообщения процессу keylist3. С любыми данными типа {Key, Value, Comment}.*\
*Протестистируйте, что процесс keylist3 обрабатывает ваши сообщения, работает со списком и возвращает результат. Проверьте почтовый ящик вашего процесса (flush/0).*
```erlang
9> PidKeylist3 = whereis(keylist3).
<0.106.0>
10> PidKeylist3 ! {self(), add, my_key1, 1, "comm1"}.
Added element  proc:<0.85.0>
{<0.85.0>,add,my_key1,1,"comm1"}
11> PidKeylist3 ! {self(), add, my_key2, 1, "comm2"}.
Added element  proc:<0.85.0>
{<0.85.0>,add,my_key2,1,"comm2"}
12> PidKeylist3 ! {self(), add, my_key3, 1, "comm3"}.
Added element  proc:<0.85.0>
{<0.85.0>,add,my_key3,1,"comm3"}
13> PidKeylist3 ! {self(), delete, my_key1}.
Remoted element key:my_key1  proc <0.85.0>
{<0.85.0>,delete,my_key1}
14> flush().
Shell got {ok,<0.102.0>}
Shell got {ok,<0.104.0>}
Shell got {ok,<0.106.0>}
Shell got {ok,1}
Shell got {ok,2}
Shell got {ok,3}
Shell got {ok,4}
ok
```
Eshell:
- Завершите процесс keylist1 с помощью функции exit(Pid, Reason). Reason отличное от normal
- P.s. Чтобы найти Pid по имени мы можем использовать команду whereis/1.
- Проверьте почтовый ящик вашего процесса (flush/0).
- Проверьте ваш pid (self/0).
- Проверьте процессы keylist2, keylist3.
- Проверьте keylist_mgr залогировал падение процесса?
- Прокомментируйте происходящее.
```erlang
15> PidKeylist1 = whereis(keylist1).
<0.102.0>
16> exit(PidKeylist1, some_reason).
=ERROR REPORT==== 15-Nov-2023::19:06:48.092000 ===
ERROR: "Process ~p failed with reason ~p~n: ~p" - [<0.102.0>,some_reason]
true
17> flush().
ok
18> self().
<0.85.0>
```
keylist1 аварийно завершился и послал сигнал слинкованному менеджеру с trap_exit. Менеджер перехватил
завершение keylist1  и, как ни в чем не бывало, продолжил работать. Наш Pid не изменился, так как наш "высший процесс"
не связан с созданными, а только мониторит менеджер.

Eshell:
- Завершите процесс keylist_mgr с помощью функции exit(Pid, Reason). Reason отличное от normal
- Проверьте почтовый ящик вашего процесса (flush/0).
- Проверьте ваш pid (self/0).
- Прокомментируйте происходящее и изменился ли ваш pid.

```erlang
21> PidKeylistMgr = whereis(keylist_mgr).
<0.101.0>
22> exit(PidKeylistMgr, some_reason).
=ERROR REPORT==== 15-Nov-2023::21:14:22.621000 ===
ERROR: "Process ~p failed with reason ~p~n: ~p" - [<0.85.0>,some_reason]
true
23> flush().
ok
24> self().
<0.85.0>
25> erlang:is_process_alive(whereis(keylist2)).
true
26> erlang:is_process_alive(whereis(keylist3)).
true
27> erlang:is_process_alive(whereis(keylist_mgr)).
true
```
Наш pid не изменился, так как сигнал выхода из Eshell менеджеру, становится сообщением с {EXIT, ...}, который обрабатывается в loop.

Eshell:
- Завершите процесс keylist_mgr с помощью keylist_mgr ! stop.
- Проверьте почтовый ящик вашего процесса (flush/0).
- Проверьте процессы keylist2, keylist3 завершились.
- Прокомментируйте происходящее и изменился ли ваш pid.
```erlang
28> PidKeylistMgr ! stop.
Terminating in state {state,[{keylist3,<0.107.0>},{keylist2,<0.105.0>}]}...
stop
29> flush().
Shell got {'DOWN',#Ref<0.431712733.991428613.175134>,process,<0.101.0>,normal}
ok
30> whereis(keylist1).
undefined
31> whereis(keylist2).
<0.105.0>
32> whereis(keylist3).
<0.107.0>
33> whereis(keylist_mgr).
undefined
34> self().
<0.85.0>
```
процессы keylist2, keylist3 не завершились, т.к. менеджер завершился по причине normal.
У нас стоял монитор из Eshella, благодаря чему, было получено сообщение о завершении.