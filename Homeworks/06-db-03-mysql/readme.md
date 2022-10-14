## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```
Команда \s
Версия сервера БД:
Server version:         8.0.31 MySQL Community Server - GPL
```


Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```
> show tables;
```

| Tables_in_test_db |
|-------------------|
| orders            |


**Приведите в ответе** количество записей с `price` > 300.
```
select * from orders where price > 300;

1 запись:
```

| id | title          | price |
|----|----------------|-------|
|  2 | My little pony |   500 |



## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```
CREATE USER 'test' 
IDENTIFIED WITH mysql_native_password BY 'test-pass'
attribute '{ "lname" : "Pretty", "fname" : "James" }';

alter user 'test' WITH MAX_QUERIES_PER_HOUR 100;

alter user 'test'
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3;
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

```
grant select on test_db.* to 'test';
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

## Ответ
|Host|User|Select_priv|Insert_priv|Update_priv|Delete_priv|Create_priv|Drop_priv|Reload_priv|Shutdown_priv|Process_priv|File_priv|Grant_priv|References_priv|Index_priv|Alter_priv|Show_db_priv|Super_priv|Create_tmp_table_priv|Lock_tables_priv|Execute_priv|Repl_slave_priv|Repl_client_priv|Create_view_priv|Show_view_priv|Create_routine_priv|Alter_routine_priv|Create_user_priv|Event_priv|Trigger_priv|Create_tablespace_priv|ssl_type|ssl_cipher|x509_issuer|x509_subject|max_questions|max_updates|max_connections|max_user_connections|plugin|authentication_string|password_expired|password_last_changed|password_lifetime|account_locked|Create_role_priv|Drop_role_priv|Password_reuse_history|Password_reuse_time|Password_require_current|User_attributes|
|----|----|-----------|-----------|-----------|-----------|-----------|---------|-----------|-------------|------------|---------|----------|---------------|----------|----------|------------|----------|---------------------|----------------|------------|---------------|----------------|----------------|--------------|-------------------|------------------|----------------|----------|------------|----------------------|--------|----------|-----------|------------|-------------|-----------|---------------|--------------------|------|---------------------|----------------|---------------------|-----------------|--------------|----------------|--------------|----------------------|-------------------|------------------------|---------------|
|%|test|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N|N| | | | |100|0|0|0|mysql_native_password|*62C4834A52EB88A9E3EBA2EFF227C58AD0248317|N|2022-10-14 10:01:12|180|N|N|N| | | |{"metadata": {"fname": "James", "lname": "Pretty"}, "Password_locking": {"failed_login_attempts": 3, "password_lock_time_days": 0}}|



## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.


## Ответ

```
Посмотреть выполненные запросы:
mysql>  SHOW PROFILES;
```

| Query_ID | Duration   | Query                     |
|----------|------------|---------------------------|
|        1 | 0.00010450 | SET profiling = 1         |
|        2 | 0.00022550 | select * from orders      |


```
Посмотреть конкретный запрос:
mysql> show profiles for query 2;
```
| Status                         | Duration |
|--------------------------------|----------|
| starting                       | 0.000067 |
| Executing hook on transaction  | 0.000007 |
| starting                       | 0.000007 |
| checking permissions           | 0.000004 |
| Opening tables                 | 0.000026 |
| init                           | 0.000004 |
| System lock                    | 0.000007 |
| optimizing                     | 0.000003 |
| statistics                     | 0.000011 |
| preparing                      | 0.000014 |
| executing                      | 0.000036 |
| end                            | 0.000002 |
| query end                      | 0.000002 |
| waiting for handler commit     | 0.000006 |
| closing tables                 | 0.000006 |
| freeing items                  | 0.000018 |
| cleaning up                    | 0.000008 |


Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```
> SHOW TABLE STATUS WHERE Name = 'orders';
```

| Name   | Engine | Version | Row_format | Rows |
|--------|--------|---------|------------|------|
| orders | **InnoDB** |      10 | Dynamic    |    5 |



Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

## Ответ

| Query_ID | Duration   | Query                                   |
|----------|------------|-----------------------------------------|
|        7 | 0.04181125 | ALTER TABLE orders ENGINE = 'MyISAM'    |
|        8 | 0.10247000 | ALTER TABLE orders ENGINE = 'InnoDB'    |

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных

```
innodb_flush_method = O_DSYNC
innodb_flush_log_at_trx_commit = 2
```

- Нужна компрессия таблиц для экономии места на диске

```
innodb_file_per_table = ON
```

- Размер буффера с незакомиченными транзакциями 1 Мб

```
innodb_log_buffer_size = 1M
```

- Буффер кеширования 30% от ОЗУ

```
innodb_buffer_pool_size = 1G
```

- Размер файла логов операций 100 Мб

```
innodb_log_file_size = 100M
```

Приведите в ответе измененный файл `my.cnf`.

## Ответ

```  
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid


# Добавленные значения

innodb_flush_method = O_DSYNC
innodb_flush_log_at_trx_commit = 2

innodb_file_per_table = ON

innodb_log_buffer_size = 1M

innodb_buffer_pool_size = 1G

innodb_log_file_size = 100M

[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/
```