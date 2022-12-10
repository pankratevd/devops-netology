# Домашнее задание к занятию "2. Работа с Playbook"

## Подготовка к выполнению

1. (Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)
2. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Приготовьте свой собственный inventory файл `prod.yml`.
```text
prod.yml:

clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 192.168.1.71
vector:
  hosts:
    vector-01:
      ansible_host: 192.168.1.72
```

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.
```text

Добавил play:

- name: Install Vector
  hosts: vector
  handlers:
    - name: Start vector service
      become: true
      ansible.builtin.service:
        name: vector
        enabled: true
        state: restarted
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.{{ vector_arch }}.rpm"
        dest: "./vector-{{ vector_version }}.rpm"
      tags:
        - distrib
        - vector
    - name: Install Vector
      become: true
      ansible.builtin.yum:
        name:
          - ./vector-{{ vector_version }}.rpm
    - name: Vector Config
      become: true
      template:
        src: files/vector/vector.toml
        dest: /etc/vector/vector.toml
      notify: Start vector service
      tags:
        - config
```

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
```text
Запустил, ошибок нет, есть предупреждение.

# ansible-lint site.yml
WARNING: PATH altered to include /usr/bin
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 1 violation(s) that are fatal
risky-file-permissions: File permissions unset or incorrect
site.yml:74 Task/Handler: Vector Config

You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - experimental  # all rules tagged as experimental

Finished with 0 failure(s), 1 warning(s) on 1 files.
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
```
При запуске с --check есть ошибка отсутсвующего файла, выполнение play прервалось. В дальнейшем при выполнении и скачивании файла данной ошибки не будет.

# ansible-playbook site.yml -i ./inventory/prod.yml --check

PLAY [Install Clickhouse] *******************************************************************************************************************************
TASK [Gathering Facts] **********************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ***************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ***************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] **********************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP **********************************************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0

```


7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```text

Результат выполнения (в системе произведены изменения, ошибок нет):

PLAY RECAP **********************************************************************************************************************************************
clickhouse-01              : ok=7    changed=6    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector-01                  : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```text
Изменения не производились:

PLAY RECAP **********************************************************************************************************************************************
clickhouse-01              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---