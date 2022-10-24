## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib` 
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

```
from elasticsearch:7.17.6
COPY elasticsearch.yml /usr/share/elasticsearch/config
EXPOSE 9200
```
- ссылку на образ в репозитории dockerhub

Ссылка:
https://hub.docker.com/repository/docker/dpankratiev/es01

```
docker pull dpankratiev/es01:v1.0
```

- ответ `elasticsearch` на запрос пути `/` в json виде

```
{
  "name" : "netology_test",
  "cluster_name" : "netology_cluster",
  "cluster_uuid" : "aWS-fvbNQOiuTiB5-wH_lA",
  "version" : {
    "number" : "7.17.6",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "f65e9d338dc1d07b642e14a27f338990148ee5b6",
    "build_date" : "2022-08-23T11:08:48.893373482Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```


Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```
PUT /ind-1
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}

PUT /ind-2
{
  "settings": {
    "index": {
      "number_of_shards": 2,  
      "number_of_replicas": 1 
    }
  }
}

PUT /ind-3
{
  "settings": {
    "index": {
      "number_of_shards": 2,  
      "number_of_replicas": 4 
    }
  }
}
```


Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```
Запрос GET /_cat/indices

Ответ:
green  open .geoip_databases rYAmjwmISt-e1dJg9QvkFQ 1 0 41 38 39mb 39mb
green  open ind-1            t00eefL_S2eg4h8WBdj01g 1 0  0  0 226b 226b
yellow open ind-3            SPBPiO2dQAKweW9raN5v6g 4 2  0  0 904b 904b
yellow open ind-2            T6BZg3y1RQy8CIyACNws1A 2 1  0  0 452b 452b

```

Получите состояние кластера `elasticsearch`, используя API.

```
Запрос GET /_cluster/health

{
    "cluster_name": "netology_cluster",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 10,
    "active_shards": 10,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 50.0
}


```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

```
Состояние индексов ind-2 и ind-3 yellow указывает на то, что индекс находятся в работоспособном состоняии, но есть утраченные шарды.

Кластер находится в статусе yellow, т.к. есть индексы в данном состоянии.
```

Удалите все индексы.

```
DELETE /ind-1
DELETE /ind-2
DELETE /ind-3
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```
PUT /_snapshot/my_repository

{
  "type": "fs",
  "settings": {
    "location": "my_backup"
  }
}

Результат вызова:

{
    "acknowledged": true
}

```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

```
PUT /_snapshot/my_repository/backup1

{
    "accepted": true
}

```

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```
ll /usr/share/elasticsearch/snapshots/my_backup
total 56
drwxrwxr-x 3 elasticsearch root  4096 Oct 24 14:27 ./
drwxrwxr-x 3 elasticsearch root  4096 Oct 24 14:27 ../
-rw-rw-r-- 1 elasticsearch root  1419 Oct 24 14:27 index-0
-rw-rw-r-- 1 elasticsearch root     8 Oct 24 14:27 index.latest
drwxrwxr-x 6 elasticsearch root  4096 Oct 24 14:27 indices/
-rw-rw-r-- 1 elasticsearch root 29264 Oct 24 14:27 meta-KNj4yOAdTAeQhoPPt_bY_g.dat
-rw-rw-r-- 1 elasticsearch root   706 Oct 24 14:27 snap-KNj4yOAdTAeQhoPPt_bY_g.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```
DELETE /test

{
    "acknowledged": true
}

PUT /test-2

{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}

GET /_cat/indices

green open test-2           7XQuBh0sRwScS1fFhc9XaQ 1 0  0 0 226b 226b
green open .geoip_databases dQdQrZYwSLCmP9KVoqNF-A 1 0 41 0 39mb 39mb


```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```

Удаляем текущие datastream и индексы
DELETE /_data_stream/*?expand_wildcards=all
DELETE /*?expand_wildcards=all

Восстанавливаем состояние кластера
POST /_snapshot/my_repository/backup1/_restore

{
  "indices": "*",
  "include_global_state": true
}


GET /_cat/indices
green open .geoip_databases PrUaklx_Qu6-Os-vC3EFxw 1 0 41 0 39mb 39mb
green open test             4Q4wW45FS2aeEq5fmYPzww 1 0  0 0 226b 226b
```