## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
```
команда: 
\l

\l[+]   [PATTERN]      list databases
```

- подключения к БД
```
команда:
\с

 \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         
```

- вывода списка таблиц

```
команда:

\dt

\dt[S+] [PATTERN]      list tables
```
- вывода описания содержимого таблиц

```
команда:

 \d[S+]  NAME           describe table, view, sequence, or index
```

- выхода из psql
```
команда:

\q
```
## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```
SELECT *
FROM pg_stats
where tablename = 'orders'
order by avg_width desc
limit 1
```
|schemaname|tablename|attname|inherited|null_frac|avg_width|n_distinct|most_common_vals|most_common_freqs|histogram_bounds|correlation|most_common_elems|most_common_elem_freqs|elem_count_histogram|
|----------|---------|-------|---------|---------|---------|----------|----------------|-----------------|----------------|-----------|-----------------|----------------------|--------------------|
|public|orders|title|false|0.0|16|-1.0| | |{"Adventure psql time",Dbiezdmin,"Log gossips","Me and my bash-pet","My little database","Server gravity falls","WAL never lies","War and peace"}|-0.3809524| | | |



## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

```
begin transaction; 

-- Создаем таблицы для разделенных данных
create table orders_less_499 (
check (price =< 499)
) inherits (orders);

create table orders_gt_499 (
check (price > 499)
) inherits (orders);

--Сохдаем индексы для таблиц
create index orders_less_499_price on orders_less_499 (price);
create index orders_gt_499_price on orders_gt_499 (price);
  
--Копируем данные в первую дочернюю таблицу
insert into orders_less_499
select * from only orders 
where price <= 499;

--Удаляем данные из родительской таблицы
delete from only orders
where price <= 499;

--Копируем данные во вторую дочернюю таблицу
insert into orders_gt_499
select * from only orders 
where price > 499;

--Удаляем данные из родительской таблицы
delete from only orders
where price > 499;

--Создаем функцию для вставки в правильную дочернюю таблицу
CREATE OR REPLACE FUNCTION orders_insert_trigger()
RETURNS TRIGGER AS $$
begin
	if (new.price <= 499) then
     insert INTO orders_less_499 VALUES (NEW.*);
    else 
     insert INTO orders_gt_499 VALUES (NEW.*);
    end if;
     RETURN NULL;
END;
$$
LANGUAGE plpgsql;

--Создаем триггер для вызова функции при вставке
CREATE TRIGGER insert_orders_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE PROCEDURE orders_insert_trigger();


COMMIT transaction;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?


```
Можно спользовать
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);

create table orders_gt_499 partition of orders
for values from (500) to (2147483647);

create table orders_less_499 partition of orders
for values from (-2147483648) to (500);
 
```
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?


```
Можно добавить constraint:

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT title_unique UNIQUE (title);
```