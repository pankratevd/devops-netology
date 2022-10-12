## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

## Ответ

[docker-compose.yml](https://github.com/pankratevd/devops-netology/blob/main/Homeworks/06-db-02-sql/files/docker-compose.yml)



## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
```
create database test_db;
create user "test-admin-user" with encrypted password '123456';
```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```
create table orders (
id serial PRIMARY key, 
title text,
price int
);

create table clients (
id serial PRIMARY key, 
surname text,
country text,
order_id integer REFERENCES orders (id)
);
CREATE INDEX country_idx ON clients (country);

```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```
grant all on ALL tables in schema public to "test-admin-user";
```
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```
create user "test-simple-user" with encrypted password '123456';
grant select, insert, update, delete  on ALL tables in schema public to "test-simple-user";
```

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)


Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

## Ответ
- итоговый список БД после выполнения пунктов выше
```
SELECT datname FROM pg_database;
```

|datnam|
|------|
|postgres|
|admin|
|template1|
|template0|
|test_db|

- описание таблиц (describe)
```
SELECT 
   table_name, 
   column_name, 
   data_type 
FROM 
   information_schema.columns
WHERE 
   table_name = 'orders';
```   
|table_name|column_name|data_type|
|----------|-----------|---------|
|orders|id|integer|
|orders|price|integer|
|orders|title|text|

```
SELECT 
   table_name, 
   column_name, 
   data_type 
FROM 
   information_schema.columns
WHERE 
   table_name = 'clients';
```   
|table_name|column_name|data_type|
|----------|-----------|---------|
|clients|id|integer|
|clients|order_id|integer|
|clients|surname|text|
|clients|country|text|

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```
SELECT * FROM information_schema.table_privileges
where grantee like 'test%'; -- (Опционально) Ограничение для созданных пользователей.
```

- список пользователей с правами над таблицами test_db

|grantor|grantee|table_catalog|table_schema|table_name|privilege_type|is_grantable|with_hierarchy|
|-------|-------|-------------|------------|----------|--------------|------------|--------------|
|admin|test-admin-user|test_db|public|orders|INSERT|NO|NO|
|admin|test-admin-user|test_db|public|orders|SELECT|NO|YES|
|admin|test-admin-user|test_db|public|orders|UPDATE|NO|NO|
|admin|test-admin-user|test_db|public|orders|DELETE|NO|NO|
|admin|test-admin-user|test_db|public|orders|TRUNCATE|NO|NO|
|admin|test-admin-user|test_db|public|orders|REFERENCES|NO|NO|
|admin|test-admin-user|test_db|public|orders|TRIGGER|NO|NO|
|admin|test-admin-user|test_db|public|clients|INSERT|NO|NO|
|admin|test-admin-user|test_db|public|clients|SELECT|NO|YES|
|admin|test-admin-user|test_db|public|clients|UPDATE|NO|NO|
|admin|test-admin-user|test_db|public|clients|DELETE|NO|NO|
|admin|test-admin-user|test_db|public|clients|TRUNCATE|NO|NO|
|admin|test-admin-user|test_db|public|clients|REFERENCES|NO|NO|
|admin|test-admin-user|test_db|public|clients|TRIGGER|NO|NO|
|admin|test-simple-user|test_db|public|orders|INSERT|NO|NO|
|admin|test-simple-user|test_db|public|orders|SELECT|NO|YES|
|admin|test-simple-user|test_db|public|orders|UPDATE|NO|NO|
|admin|test-simple-user|test_db|public|orders|DELETE|NO|NO|
|admin|test-simple-user|test_db|public|clients|INSERT|NO|NO|
|admin|test-simple-user|test_db|public|clients|SELECT|NO|YES|
|admin|test-simple-user|test_db|public|clients|UPDATE|NO|NO|
|admin|test-simple-user|test_db|public|clients|DELETE|NO|NO|



## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```
insert into orders (title, price) 
values 
('Шоколад', 10),
('Принтер', 3000),
('Книга', 500),
('Монитор', 7000),
('Гитара', 4000);


insert into clients (surname, country) 
values 
('Иванов Иван Иванович', 'USA'),
('Петров Петр Петрович', 'Canada'),
('Иоганн Себастьян Бах', 'Japan'),
('Ронни Джеймс Дио', 'Russia'),
('Ritchie Blackmore', 'Russia');
```


Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

## Ответ

```
select count(id) from orders; 
select count(id) from clients;

Результат 5 для каждой таблицы.
```


## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

```
update clients 
set order_id = (select o.id from orders o where o.title = 'Книга')
where surname = 'Иванов Иван Иванович';

update clients 
set order_id = (select o.id from orders o where o.title = 'Монитор')
where surname = 'Петров Петр Петрович';

update clients 
set order_id = (select o.id from orders o where o.title = 'Гитара')
where surname = 'Иоганн Себастьян Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```
select c.surname 
from clients c 
where order_id is not null
```
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```
explain select c.surname 
from clients c 
where order_id is not null
```

Результат:

|QUERY PLAN|
|----------|
|Seq Scan on clients c  (cost=0.00..18.10 rows=806 width=32)|
|  Filter: (order_id IS NOT NULL)|

```
При выполнении запроса будет использоваться последовательное чтение всех строк, при этом будет применен фильтр не null.
Оценочное количество строк для чтения - 801, их размер 32 байта

Оценочная стоимость запроса: 18.10
```

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.

## Ответ
```
Создание backup:
docker exec pg1 pg_dump -U admin -d test_db --file /backup/bck.dmp -Fc

Остановка docker-compose:
docker-compose stop

Далее запущен новый контейнер
конфигурация приведена в: 
``` 
[docker-compose2.yml](https://github.com/pankratevd/devops-netology/blob/main/Homeworks/06-db-02-sql/files/docker-compose2.yml)

``` 
с новым располоэением файлов БД и подключенным backup разделом с копией.
docker-compose up -d

Выполнены команды:
создание БД:
docker exec pg2 createdb -U admin test_db

восстановление БД:
docker exec pg2 pg_restore -U admin -d test_db  /backup/bck.dmp

```