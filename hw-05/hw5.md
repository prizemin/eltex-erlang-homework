# Задание 1

*В Eshell создайте алиасы для функций  recursion:tail_fac/1 recursion:tail_duplicate/1 и вызовите функции через алиасы.*

```
1> l(recursion).
{module,recursion}
2> Fac = fun recursion:tail_fac/1.
fun recursion:tail_fac/1
3> Fac(5).
factorial 5
factorial 4
factorial 3
factorial 2
factorial 1
120
4> Dup = fun recursion:tail_duplicate/1.
fun recursion:tail_duplicate/1
5> Dup([1,2,3]).
[1,1,2,2,3,3]
```

# Задание 2

*Напишите анонимные функции*

1) Для умножения 2х элементов\

```
7> Multipy2 = fun(X,Y) -> X * Y end.
#Fun<erl_eval.41.105768164>
8> Multiply2(2, 100).
200
```
2) Преобразуйте функцию converter:to_rub/1 (из прошлой ДР) в анонимную  функцию. 

```
15> ToRub = fun ({usd, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 75.5}; ({euro, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 80}; ({lari, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 29}; ({peso, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount *3}; ({krone, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 10}; (_) -> {error, badarg} end.
#Fun<erl_eval.42.105768164>
16> ToRub({usd, 100}).
{ok,7550.0}
17> ToRub({peso, 12}).
{ok,36}
18> ToRub({yene, 30}).
{error,badarg}
19> ToRub({euro, -15}).
{error,badarg}
```

# Задание 3

*В Eshell Вызовите функции (данные для Persons используйте из таблицы ДР2):*

*Получите список из персон старше 30 лет:*

```
4> persons:filter(fun(#person{age = Age}) -> Age >= 30 end, Persons).
[#person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
```
*Получите список из мужчин:*

```
persons:filter(fun(#person{gender = Gender}) -> Gender == male end, Persons).
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 3,name = "Jack",age = 34,gender = male}]
```
При использовании констант из заголовочного файла Eshell заругался, поэтому использовал обычный атом.

*Проверьте, что в списке есть хотя бы одна женщина:*

```
6> persons:any(fun(#person{gender = Gender}) -> Gender == female end, Persons).
true
```
*Проверьте что в списке все старше 20 (включая):*

```
7> persons:all(fun(#person{age = Age}) -> Age >= 20 end, Persons).
true
```
*Проверьте, что в списке все младше 30 (включая):*

```
8> persons:all(fun(#person{age = Age}) -> Age =< 30 end, Persons).
false
```
*Обновите возраст (+1) персоне с именем Jack:*

```
UpdateJackAge = fun(#person{name = "Jack", age = Age} = Person) -> Person#person{age = Age + 1}; (Person) -> Person end.
#Fun<erl_eval.42.105768164>
10> persons:update(UpdateJackAge, Persons).
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 35,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
```

*Обновите возраст (-1) всем женщинам:*

```
11> UpdateFemaleAge = fun(#person{gender = ?FEMALE, age = Age} = Person) -> Person#person{age = Age - 1}; (Person) -> Person end.
* 1:40: syntax error before: '?'
11> UpdateFemaleAge = fun(#person{gender = female, age = Age} = Person) -> Person#person{age = Age - 1}; (Person) -> Person end.
#Fun<erl_eval.42.105768164>
12> persons:update(UpdateFemaleAge, Persons).
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 19,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 53,gender = female}]
```
# Задание 4

*Добавьте функцию catch_all/1 в новый модуль exceptions.erl*

*В Eshell выполните:*
exceptions:catch_all(fun() -> 1/0 end).\

```
16> exceptions:catch_all(fun() -> 1/0 end).
Action #Fun<erl_eval.43.105768164> failed, reason badarith
error
```
в Reason записалась причина badarith, ошибка при делении на ноль, либо при арифметических операциях с слагаемыми разного типа.

exceptions:catch_all(fun() -> throw(custom_exceptions) end).\

```
17> exceptions:catch_all(fun() -> throw(custom_exceptions) end).
Action #Fun<erl_eval.43.105768164> failed, reason custom_exceptions
throw
```
Передали анонимную функцию, которая бросает throw с атомом custom_exeption, который возвращается в качестве значениия и выводится значение, которое было брошено.

exceptions:catch_all(fun() -> exit(killed) end).\

```
18> exceptions:catch_all(fun() -> exit(killed) end).
Action #Fun<erl_eval.43.105768164> failed, reason killed
exit
```
Перехватили исключение, затем выводится значение, которое привело к завершению процесса.

exceptions:catch_all(fun() -> erlang:error(runtime_exception) end).\

```
19> exceptions:catch_all(fun() -> erlang:error(runtime_exception) end).
Action #Fun<erl_eval.43.105768164> failed, reason runtime_exception
error
```
