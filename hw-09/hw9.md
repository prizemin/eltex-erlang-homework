# 09. Инструменты Erlang: Spec (Dialyzer), Edoc
## Задание \#1
Обновите модуль `keylist_mgr.erl.`

Добавьте в keylist_mgr.erl - API функции для всех сообщений.
-  {From, start_child, Name}
-  {From, stop_child, Name}
-  stop
-  {From, get_names}

Обновите API для keylist_mgr:start_child/1 вместо Name будем использовать Params, пример:
{From, start_child, Params}
где Params :: #{name => atom(), restart => permanent | temporary}
Если процесс со стратегией permanent добавьте его в список #state.permanent.
Если restart = permanent, то если keylist (процесс keylist.erl) завершается аварийно - мы должны его перезапустить. Не забудьте обновить #state.permanent (удалить старый Pid и добавить новый перезапущенный Pid)
Если restart = temporary, то если keylist завершается аварийно - мы должны только залогировать и ничего не запускать.
В обоих случаях не забудьте обновить #state.children.

Обновите рекорд #state{children, permanent}. permanent мы будем использовать для сохранения Pid процессов, которые нам нужно перезапустить в случае их падения.  В #state.permanent мы будем хранить список [Pid1, …PidN]. Подумайте какие значения по умолчанию нам нужно задать для поля permanent.

Проверьте, что стратегия перезапуска restart => permanent | temporary работает. С помощью Eshell. Запустите процессы и остановите их с использованием exit(Pid, Reason). whereis/1 чтобы посмотреть жив ли процесс по его имени.
```erlang
1> c(keylist).
{ok,keylist}
2> rr("keylist.erl").
[state]
3> c(keylist_mgr).
{ok,keylist_mgr}
4> SelfPid = self().
<0.85.0>
5> keylist_mgr:start().
Started pid <0.101.0>
{ok,<0.101.0>,#Ref<0.2379313187.3633840133.251492>}
6> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).
Linked pid <0.103.0>
ok
7> keylist_mgr:start_child(#{name => keylist2, restart => temporary}).
Linked pid <0.105.0>
ok
8> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).
Linked pid <0.107.0>
ok
9> keylist_mgr:start_child(#{name => keylist4, restart => temporary}).
Linked pid <0.109.0>
ok
10> exit(whereis(keylist1), kill).
Linked pid <0.111.0>  %Переназначился новый Pid для процесса keylist1, входным параметром restart в мапе был permanent.
=ERROR REPORT==== 19-Nov-2023::07:45:18.795000 ===

Process keylist1 failed with reason: killed

true
11> whereis(keylist1).
<0.111.0>
12> exit(whereis(keylist2), kill). %Здесь же просто залогировалось падение процесса и он завершился.
=ERROR REPORT==== 19-Nov-2023::07:46:14.999000 ===

Process keylist2 failed with reason: killed

true
13> whereis(keylist2).
undefined
14> keylist_mgr ! stop.
Terminating in state {state,[{keylist1,<0.111.0>},
                             {keylist4,<0.109.0>},
                             {keylist3,<0.107.0>}],
                             [<0.111.0>,<0.107.0>]}...
keylist terminating in state {state,[],0}
keylist terminating in state {state,[],0}
keylist terminating in state {state,[],0}
stop
15> whereis(keylist1).
undefined
16> whereis(keylist2).
undefined
17> whereis(keylist3).
undefined
18> whereis(keylist_mgr).
undefined
%При завершении выводим State, также видно, что в list permanent добавились Pid(ы) и процессу keylist1 назначен новый идентификатор.
%Также, при завершении keylist_mgr завершились все дочерние процессы.
```
Добавьте spec в keylist_mgr.erl для экспортируемых функций и рекордов

Добавьте документацию для модуля keylist_mgr.erl и экспортируемых функций

## Задание \#2
Обновите модуль keylist.erl.
Добавьте в keylist.erl - API функции для всех сообщений.
- {From, add, Key, Value, Comment};
- {From, is_member, Key};
- {From, take, Key};
- {From, find, Key};
- {From, delete, Key}

Теперь вы можете вызывать keylist:add(keylist1, key1, “value1”, “comment1”).

Добавьте spec в keylist.erl для экспортируемых функций и рекордов
Добавьте документацию для модуля keylist.erl и экспортируемых функций
