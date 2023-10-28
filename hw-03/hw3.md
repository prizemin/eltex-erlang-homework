# Задание1
*Используя данные из 2 ДР переменной Persons*

```
1> rd(person, {id, name, age, gender}).
person
2> Persons = [#person{id = 1, name = "Bob", age = 23, gender = male},
              #person{id = 2, name = "Kate", age = 20, gender = female},
              #person{id = 3, name = "Jack", age = 34, gender = male}, 
              #person{id = 4, name = "Nata", age = 54, gender = female}].

[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
```
*выполните команды:*
1.[_, SecondPerson, _, _] = Persons. 

*Проверьте и объясните присвоенное значение SecondPerson.*

```
3>[_, SecondPerson, _, _] = Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
4> SecondPerson.
#person{id = 2,name = "Kate",age = 20,gender = female}
```
С помощью паттерн-матчинга, присваиваем переменной SecondPerson значение второго элемента списка Persons, которае является вторым рекордом.


2.SecondName = SecondPerson#person.name.
  SecondAge = SecondPerson#person.age.

```
5> SecondName = SecondPerson#person.name.
"Kate"
6> SecondAge = SecondPerson#person.age.
20
```
Присваиваем переменным SecondName и SecondAge значения из рекорда SecondPerson по ключам, обращаясь через "."

3.[_, #person{name = SecondName, age = SecondAge} | _Rest] = Persons. 
  SecondName.
  SecondAge.

*Проверьте присвоенные на 2 шаге значения SecondName, SecondAge и объясните почему на 3 шаге сопоставление с образцом (pattern matching) прошло успешно.*

```
7> [_, #person{name = SecondName, age = SecondAge}| _Rest] = Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
8> SecondName.
"Kate"
9> SecondAge.
20
```
Присвоенные значения SecondName и SecondAge остались теми же. Шаблон #person{name = SecondName, age = SecondAge} соответствует записи типа person. Паттерн-матчинг прошел успешно, потому что он соответсвует ожидаемой структуре данных в списке Persons.

4.Persons.

*Проверьте, что список Persons не изменился.*

```
10> Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
```
Список Persons не изменился.

5.SecondPerson#person{age = 21}.

*Проверьте, что список Persons и SecondPerson не изменились.*

```
11> SecondPerson#person{age = 21}.
#person{id = 2,name = "Kate",age = 21,gender = female}
12> Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "Jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
13> SecondPerson.
#person{id = 2,name = "Kate",age = 20,gender = female}
```

Список Persons и SecondPerson не изменились. Мы можем изменять рекорды, но данные нужно присваивать к другой переменной. В 11> данные не присваиваются никакой переменной, а просто возвращаются.

# Задание2

*Создайте список maps, которые содержат данные о 4х человек. Данные возьмите те же самые, что мы использовали до этого в ДР 2. Присвойте данные переменной Persons. Persons = [#{id => 1, name => “Karl”, age => 87, gender => male}, #{id => 2, name => “Kate”, age => 86, gender => female}, …]*

```
15> Persons = [#{id => 1, name => "Bob", age => 23, gender => male}, #{id => 2, name => "Kate", age => 20, gender => female}, #{id => 3, name => "Jack", age => 34, gender => male}, #{id => 4, name => "Nata", age => 54, gender => female}].
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
```
*Выполните команды:*

1.[FirstPerson | _] = Persons.

*Проверьте и объясните присвоенное значение FirstPerson.*

```
16> [FirstPerson | _] = Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
17> FirstPerson.
#{id => 1,name => "Bob",age => 23,gender => male}
```

Вытаскиваем голову списка Persons, используя паттерн-матчинг. Присвоили FirstPerson первую map из списка.

2.[_, _, #{name := Name, age := Age},  _] = Persons. 
  *Проверьте и объясните присвоенное значение Name, Age.*
   Name.
   Age.

```
18> [_, _, #{name := Name, age := Age},  _] = Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
19> Name.
"Jack"
20> Age.
```
Здесь нам нужно вытащить только поля name и age. Связываем значения полей name и age c переменными Name и Age. После выполнения паттерн-матчинга переменная Name присваивается значению "Jack", а Age присваивается значение 34.

3.[_First, _Second, #{name := Name, age := Age} | _Rest] = Persons. 

*Проверьте и объясните присвоенные значения Name, Age в пункте 2 и 3. Почему команда 3 завершилась успешно (Name, Age уже связаны)?*

```
21> [_First, _Second, #{name := Name, age := Age} | _Rest] = Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
22>Name.
"Jack"
23> Age.
34
```
Тот же образец паттерн-матчинга, только теперь вместо "_" еще указываем имя(_First и т.д.), но только для понимания. Команда 3 завершилась успешно, потому что переменные Name и Age уже были привязаны к значениям полей из мапы в предыдущем паттерн-матчинге.

4.Persons. 

*Проверьте, что список Persons не изменился.*

```
24> Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
```

Без изменений.

5.FirstPerson#{age := 24}.

*Проверьте, что список Persons и FirstPerson не изменились. Почему?*

```
25> FirstPerson#{age := 24}.
#{id => 1,name => "Bob",age => 24,gender => male}
26> Persons.
[#{id => 1,name => "Bob",age => 23,gender => male},
 #{id => 2,name => "Kate",age => 20,gender => female},
 #{id => 3,name => "Jack",age => 34,gender => male},
 #{id => 4,name => "Nata",age => 54,gender => female}]
27> FirstPerson.
#{id => 1,name => "Bob",age => 23,gender => male}
```

В этой команде мы создаем новую мапу на основе FirstPerson но с обновленным age. Таким образом, если бы мы хотели обновить данные в FirstPerson нужно было бы выполнить команду: "FirstPerson = FirstPerson#{age := 24}."

6.FirstPerson#{address := “Mira 31”}.

*Проверьте и объясните результат.*

```
28> FirstPerson#{address := "Mira 31"}.
** exception error: bad key: address
     in function  maps:update/3
        called as maps:update(address,"Mira 31",
                              #{id => 1,name => "Bob",age => 23,gender => male})
        *** argument 3: not a map
     in call from erl_eval:'-expr/6-fun-0-'/2 (erl_eval.erl, line 311)
     in call from lists:foldl/3 (lists.erl, line 1594)
```
Ошибка. Мы попытались обновить поле adress, которого нет в мапе.

# Задание3

*Создайте модуль converter.erl с функцией to_rub/1 на вход которой поступает тип валюты и сумма и возвращается результат конвертации в рубли {ok, Result} или {error, badarg}.*

*Запустите EShell из папки где у вас находится файл converter.erl В консоли скомпилируйте файл и вызовите функции:*
c(“converter.erl”).
converter:to_rub({usd, 100}).
converter:to_rub({peso, 12}).
converter:to_rub({yene, 30}).
converter:to_rub({euro, -15}).

```
1> c("converter.erl").
{ok,converter}
2> converter:to_rub({usd, 100}).
Convert usd to rub, amount 100
{ok,7550.0}
3> converter:to_rub({peso, 12}).
Convert peso to rub, amount 12
{ok,36}
4> converter:to_rub({yene, 30}).
Invalid currency or amount
{error,badarg}
5> converter:to_rub({euro, -15}).
Invalid currency or amount
{error,badarg}
6>
```
Строка 4 завершилась ошибкой, т.к. в параметре функции была валюта, которая не соответствует описанным вариантам.
Строка 5 завершилась ошибкой, т.к. параметр Amount <0. 