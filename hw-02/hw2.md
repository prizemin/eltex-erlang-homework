# Задание1
*Используя данные переменной Persons*

```
1> Persons = [{1, "Bob", 23, male}, {2, "Kate", 20, female}, {3, "Jack", 34, male}, {4, "Nata", 54, female}].
 [{1, "Bob", 23, male},
  {2, "Kate", 20, female},
  {3, "Jack", 34, male}, 
  {4, "Nata", 54, female}]
2> Persons. 
 [{1,"Bob", 23, male}, 
  {2, "Kate", 20, female}, 
  {3,"Jack", 34, male}, 
  {4, "Nata", 54, female}] 
```
*Выполните команды:*
1.[First | Rest] = Persons. 

*Проверьте и объясните присвоенные значения First, Rest.*

```
3> [First|Rest] = Persons. 
[{1,"Bob", 23, male},
 {2, "Kate", 20, female}, 
 {3,"Jack", 34, male}, 
 {4, "Nata", 54, female}] 
4> First.
{1,"Bob",23,male}
5> Rest.
[{2, "Kate", 20, female}, 
 {3,"Jack",34,male}, 
 {4,"Nata", 54, female}] 
```
В First помещается голова списка Persons, т.е. первый кортеж. В Rest – все остальное – список из оставшихся кортежей.

2.[Second | Rest1] = Rest.

*Проверьте и объясните присвоенные значения Second, Rest.*

```
6> [Second|Rest1] = Rest. 
[{2, "Kate", 20, female}, 
 {3,"Jack", 34, male}, 
 {4, "Nata", 54, female}]
7> Second.
{2,"Kate", 20, female} 
8> Rest.
[{2, "Kate", 20, female},
 {3,"Jack",34,male},
 {4,"Nata", 54, female}]
9> Rest1.
[{3,"Jack",34,male}, {4, "Nata", 54, female}] 
```
Теперь мы, фактически, разделяем список Rest на голову Second(этой переменной будет присвоен первый элемент списка Rest) и хвост Rest1 – список из оставшихся таплов.

3.[Third, Fourth | Rest2] = Rest1.

*Проверьте и объясните присвоенные значения Third, Fourth, Rest2.*

```
10> [Third, Fourth| Rest2] = Rest1. 
[{3,"Jack", 34, male}, {4, "Nata", 54, female}] 
11> Third.
{3,"Jack", 34, male}
12> Fourth.
{4,"Nata", 54, female}
13> Rest2.
[]
```
Third мы присваиваем первый элемент Rest1, Fourth – второй элемент, а в Rest2 у нас записывается пустой список [] , т.к., правильный список это такой список, последним элементом которого является пустой список.

4.Persons. 

*Проверьте что список Persons не изменился.*

```
14> Persons.
[{1,"Bob", 23, male},
 {2, "Kate", 20, female},
 {3,"Jack",34,male},
 {4,"Nata", 54, female}]
```
Список Persons не изменился.

# Задание2

*Создайте список records, которые содержат данные о 4х человек. Данные приведены в таблице*

```
1> rd(person,{id, name, age, gender}).
person
2> person.
person
3> Person1 = #person{id = 1, name = "Bob", age = 23, gender = male}.
#person{id = 1,name = "Bob",age = 23,gender = male}
4> Person2 = #person{id = 2, name = "Kate", age = 20, gender = female}.
#person{id = 2,name = "Kate",age = 20,gender = female}
5> Person3 = #person{id = 3, name = "jack", age = 34, gender = male}.
#person{id = 3,name = "jack",age = 34,gender = male}
6> Person4 = #person{id = 4, name = "Nata", age = 54, gender = female}.
#person{id = 4,name = "Nata",age = 54,gender = female}
7> Persons = [Person1, Person2, Person3, Person4].
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
```
Присвоил каждую запись соответсвующей переменной, чтобы было удобнее и поместил в список. Далее присвоил все данные переменной Persons.

*Выполните команды:*

1.[FirstPerson | _] = Persons. 

*Проверьте и объясните присвоенное значение FirstPerson.*

```
8> [FirstPerson|_] = Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
9> FirstPerson.
#person{id = 1,name = "Bob",age = 23,gender = male}
```
Используя паттерн-матчинг отделили голову списка Persons и присвоили переменной FirstPerson значение первого элемента списка.

2.[_, SecondPerson, _, _] = Persons

*Проверьте и объясните присвоенное значение SecondPerson.*

```
10> [_,SecondPerson, _, _] = Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
11> SecondPerson.
#person{id = 2,name = "Kate",age = 20,gender = female}
```
Так же, вытащили из списка 2 элемент и присвоили соответсвующей переменной SecondPerson.

3.[_, _, SecondPerson | _] = Persons.

*Проверьте и объясните ошибку*

```
12> [_,_,SecondPerson|_] = Persons.
** exception error: no match of right hand side value
                    [#person{id = 1,name = "Bob",age = 23,gender = male},
                     #person{id = 2,name = "Kate",age = 20,gender = female},
                     #person{id = 3,name = "jack",age = 34,gender = male},
                     #person{id = 4,name = "Nata",age = 54,gender = female}]
```
Ошибка в связи с тем, что переменная SecondPerson уже "bound", а мы пытаемся перезаписать в неё значение 3-го элемента списка.

4.SecondName = SecondPerson#person.name.
  SecondAge = SecondPerson#person.age.

```
13> SecondName = SecondPerson#person.name.
"Kate"
14> SecondAge = SecondPerson#person.age.
20
```
Здесь мы назначаем переменным значения, вытягивая их из record по ключу.


5.Persons. 
*Проверьте, что список Persons не изменился.*

```
15> Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
```
Persons без изменений


6.SecondPerson#person{age = 21}.
*Проверьте, что список Persons и SecondPerson не изменились.*

```
16> SecondPerson#person{age = 21}.
#person{id = 2,name = "Kate",age = 21,gender = female}
17> Persons.
[#person{id = 1,name = "Bob",age = 23,gender = male},
 #person{id = 2,name = "Kate",age = 20,gender = female},
 #person{id = 3,name = "jack",age = 34,gender = male},
 #person{id = 4,name = "Nata",age = 54,gender = female}]
18> SecondPerson.
#person{id = 2,name = "Kate",age = 20,gender = female}
19>
```
Всё без изменений!


