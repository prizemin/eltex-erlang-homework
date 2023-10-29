# Задание 1

*В консоли скомпилируйте файл и вызовите функции:*

c(“converter.erl”).\
converter:to_rub2({usd, 100}).\
converter:to_rub2({peso, 12}).\
converter:to_rub2({yene, 30}).\
converter:to_rub2({euro, -15}).\

*Вызовите функцию to_rub3/1 и проверьте, что вы получили тот же результат.*

```
1> c(converter).
{ok,converter}
2> converter:to_rub2({usd, 100}).
Convert usd to rub, amount: 100
Converted usd to rub, amount 100, Result {ok,7550.0}
{ok,7550.0}
3> converter:to_rub2({peso, 12}).
Convert peso to rub, amount: 12
Converted peso to rub, amount 12, Result {ok,36}
{ok,36}
4> converter:to_rub2({yene, 30}).
Can't convert to rub, error {yene,30}
Converted yene to rub, amount 30, Result {error,badarg}
{error,badarg}
5> converter:to_rub2({euro, -15}).
Can't convert to rub, error {euro,-15}
Converted euro to rub, amount -15, Result {error,badarg}
{error,badarg}
6> converter:to_rub3({usd, 100}).
Convert usd to rub, amount: 100
{ok,7550.0}
7> converter:to_rub3({peso, 12}).
Convert peso to rub, amount: 12
{ok,36}
8> converter:to_rub3({yene, 30}).
Can't convert to rub, error {yene,30}
{error,badarg}
9> converter:to_rub3({euro, -15}).
Can't convert to rub, error {euro,-15}
{error,badarg}
```
Результат тот же.

# Задание 2

*Запустите EShell из папки где у вас находится файл converter.erl В консоли скомпилируйте файл и вызовите функции:*

c(“converter.erl”).\
converter:rec_to_rub(#conv_info{type = usd, amount = 100, commission = 0.01}).\
converter:rec_to_rub(#conv_info{type = peso, amount = 12, commission = 0.02}).\
converter:rec_to_rub(#conv_info{type = yene, amount = 30, commission = 0.02}).\
converter:rec_to_rub(#conv_info{type = euro, amount = -15, commission = 0.02}).\

```
7> converter:rec_to_rub(#conv_info{type = usd, amount = 100, commission = 0.01}).
Converted usd to rub after deduction of commission, comm: 0.01, Result {ok,7474.5}
{ok,7474.5}
8> converter:rec_to_rub(#conv_info{type = peso, amount = 12, commission = 0.02}).
Converted peso to rub after deduction of commission, comm: 0.02, Result {ok,35.28}
{ok,35.28}
9> converter:rec_to_rub(#conv_info{type = yene, amount = 30, commission = 0.02}).
Can't convert to rub, error {conv_info,yene,30,0.02}
Converted yene to rub after deduction of commission, comm: 0.02, Result {error,badarg}
{error,badarg}
10> converter:rec_to_rub(#conv_info{type = euro, amount = -15, commission = 0.02}).
Can't convert to rub, error {conv_info,euro,-15,0.02}
Converted euro to rub after deduction of commission, comm: 0.02, Result {error,badarg}
{error,badarg}
```

*Запустите EShell из папки где у вас находится файл converter.erl В консоли скомпилируйте файл и вызовите функции:*

c(“converter.erl”).\
converter: map_to_rub(#{type => usd, amount => 100, commission => 0.01}).\
converter: map_to_rub(#{type => peso, amount => 12, commission => 0.02}).\
converter: map_to_rub(#{type => yene, amount => 30, commission => 0.02}).\
converter: map_to_rub(#{type => euro, amount => -15, commission => 0.02}).\

```
12> c(converter).
{ok,converter}
13> converter: map_to_rub(#{type => usd, amount => 100, commission => 0.01}).
{ok,7474.5}
14> converter: map_to_rub(#{type => peso, amount => 12, commission => 0.02}).
{ok,35.28}
15> converter: map_to_rub(#{type => yene, amount => 30, commission => 0.02}).
Can't convert to rub, invalid currency #{type => yene,amount => 30,commission => 0.02}
{error,badarg}
16> converter: map_to_rub(#{type => euro, amount => -15, commission => 0.02}).
Can't convert to rub, invalid currency #{type => euro,amount => -15,commission => 0.02}
{error,badarg}
```

# Задание 3.1

*Преобразуйте функцию fac/1 (из лекции) в хвостовую tail_fac/1.*

*Вызовите функцию из Eshell:*

recursion:tail_fac(X).  %% X -  любое положительное число\
recursion:tail_fac(0).\

```
29> recursion:tail_fac(4).
factorial 4
factorial 3
factorial 2
factorial 1
24
30> recursion:tail_fac(0).
1
```
