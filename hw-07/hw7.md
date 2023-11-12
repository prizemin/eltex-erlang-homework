**Eshell:**\
*Проверьте ваш pid (self/0).*\
*Создайте 2 процесса PidMonitor, PidLinked:*\
keylist:start_monitor(monitored).\
keylist:start_link(linked).\

```
3> self().
<0.85.0>
4> {_, PidMonitor, _} = keylist:start_monitor(monitored).
Started pid <0.96.0>
{ok,<0.96.0>,#Ref<0.380036310.1386479622.127106>}
5> PidMonitor.
<0.96.0>
6> {_, PidLinked} = keylist:start_link(linked).
Linked pid <0.102.0>
{ok,<0.102.0>}
```
Создал два процесса, с использованием паттерн-матчинга вытащил pid(ы)

*Отправьте сообщения процессу Linked. С любыми данными типа {Key, Value, Comment}.*\
*Протестистируйте, что процесс Linked обрабатывает ваши сообщений, работает со списком и возвращает результат. Проверьте почтовый ящик вашего процесса (flush/0).*

```
7> PidLinked ! {self(), add, mykey1, 1, "comm1"}.
Added element  proc:<0.85.0>
{<0.85.0>,add,mykey1,1,"comm1"}
8> PidLinked ! {self(), add, mykey2, 1, "comm2"}.
Added element  proc:<0.85.0>
{<0.85.0>,add,mykey2,1,"comm2"}
9> PidLinked ! {self(), add, mykey3, 1, "comm3"}.
Added element  proc:<0.85.0>
{<0.85.0>,add,mykey3,1,"comm3"}
10> flush().
Shell got {ok,1}
Shell got {ok,2}
Shell got {ok,3}
ok
11> PidLinked ! {self(), delete, mykey2}.
Remoted element key:mykey2  proc <0.85.0>
{<0.85.0>,delete,mykey2}
12> flush().
Shell got {ok,4}
```
Протестировал - процесс Linked обрабатывает сообщения, работает со списком и возвращает результат. При проверке flush()/1 видим сообщения в ящике.

*Завершите процесс Monitored с помощью функции exit(Pid, Reason).*\
*P.s. Чтобы найти Pid по имени мы можем использовать команду whereis/1.*\
*Проверьте почтовый ящик вашего процесса (flush/0).*\
*Проверьте ваш pid (self/0).*\
*Прокомментируйте содержимое почтового ящика и изменился ли ваш pid.*

```
13> Monitored = whereis(monitored).
<0.96.0>
14> exit(Monitored, some_reason).
true
15> flush().
Shell got {'DOWN',#Ref<0.442028647.326631427.174652>,process,<0.96.0>,
                  some_reason}
ok
16> self().
<0.85.0>
```
Содержимое почтового ящика с уведомлением о завершении. Наш pid не изменился, тк эти процессы не связаны, а основной процесс просто наблюдает за <0.96.0>(Monitored).


*Завершите процесс Linked с помощью функции exit(Pid, Reason).*\
*Проверьте почтовый ящик вашего процесса (flush/0).*\
*Проверьте ваш pid (self/0).*\
*Прокомментируйте происходящее и изменился ли ваш pid.*

```
17> PidLinked = whereis(linked).
<0.99.0>
18> self().
<0.85.0>
19> flush().
ok
20> exit(PidLinked, some_reason).
** exception exit: some_reason
21> flush().
ok
22> self().
<0.114.0>
```
При завершении одного из залинкованных процессов, все связанные тоже завершаются. Поэтому нашему основному процессу, после завершения Linked, переназначился новый pid.
А <0.85.0> завершился. Содержимое почтового ящика пусто, тк процесс завершился.

*Eshell:*\
Вызовите функцию process_flag(trap_exit, true).\
Запустите еще раз keylist:start_link(linked).\
Завершите процесс Linked с помощью функции exit(Pid, Reason). Reason отличное от normal\
Проверьте почтовый ящик вашего процесса (flush/0).\
Проверьте ваш pid (self/0).\

```
22> self().
<0.114.0>
23>  process_flag(trap_exit, true).
false
24> keylist:start_link(linked).
Linked pid <0.119.0>
{ok,<0.119.0>}
25> PidLinked2 = whereis(linked).
<0.119.0>
26> exit(PidLinked2, some_reason).
true
27> flush().
Shell got {'EXIT',<0.119.0>,some_reason}
ok
28> self().
<0.114.0>
```
Несмотря на то, что процессы слинкованы, завершая процесс, при использовании "process_flag(tpap_exit, true)", наш процесс не падает.
А также, нам передается сообщение в почтовый ящик, из-за чего процесс завершился.

*Вызовите функцию process_flag(trap_exit, false).*\
*Запустите keylist:start_link(linked1) и keylist:start_link(linked2). У вас теперь два процесса связаны с вашим процессом.*\
*Завершите процесс Linked1 с помощью функции exit(Pid, Reason). Reason отличное от normal*\
*Проверьте ваш pid (self/0). Изменился ли ваш pid?*\
*Проверьте состояние процесса Linked2. Прокомментируйте.*

```
28> self().
<0.114.0>
29> process_flag(trap_exit, false).
true
30> keylist:start_link(linked1).
Linked pid <0.126.0>
{ok,<0.126.0>}
31> keylist:start_link(linked2).
Linked pid <0.128.0>
{ok,<0.128.0>}
32> PidLinked1 = whereis(linked1).
<0.126.0>
33> exit(PidLinked1, some_reason).
** exception exit: some_reason
34> self().
<0.131.0>
35> process_info(linked2).
** exception error: bad argument
     in function  process_info/1
        called as process_info(linked2)
        *** argument 1: not a pid
36> PidLinked2 = whereis(linked2).
** exception error: no match of right hand side value undefined
37> whereis(linked2).
undefined
```
Так как у нас создалось два процесса, слинкованных с <0.114.0>, при установке флага в false,
если мы завершим слинкованный процесс, он потащит за собой все остальные и ящик у такого процесса будет пустой. 
Соответственно, pid "нашего" процесса переназначился.
