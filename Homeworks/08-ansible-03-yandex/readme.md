1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

```text
Серверы создаются при помощи terraform, после создания в /group_vars/all создается файл с внешними ip серверов, которые используются в inventory. 
```

Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
```text
Подготовлены play:
- name: Install Nginx
  hosts: lighthouse
  handlers:
    - name: start-nginx
      become: true
      command: nginx
    - name: reload-nginx
      become: true
      command: nginx -s reload
  tasks:
    - name: NGINX |install epel-release
      become: true
      ansible.builtin.yum:
        name: epel-release
        state: present
      tags:
        - distrib
        - nginx
    - name: NGINX | Install NGINX
      become: true
      ansible.builtin.yum:
        name: nginx
        state: present
      tags:
        - distrib
        - nginx
      notify: start-nginx
    - name: Config NGINX
      become: true
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        mode: 0644
      tags:
        - config
        - nginx
      notify: reload-nginx
- name: Install Lighthouse
  hosts: lighthouse
  handlers:
    - name: nginx-reload
      become: true
      command: nginx -s reload
  pre_tasks:
    - name: Lighthouse | install dependencies
      become: true
      ansible.builtin.yum:
        name: git
        state: present
      tags:
        - dependencies
        - lighthouse
  tasks:
    - name: Lighthouse | copy from git
      become: true
      git:
        repo: "{{ lighthouse_vcs }}"
        version: master
        force: true
        update: true
        dest: "{{ lighthouse_location_dir }}"
      tags:
        - distrib
        - lighthouse
      notify: nginx-reload
```
5. Приготовьте свой собственный inventory файл `prod.yml`.
```text
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host:  "{{ clickhouse }}"
      ansible_user: centos
vector:
  hosts:
    vector-01:
      ansible_host: "{{ vector }}"
      ansible_user: centos
lighthouse:
  hosts:
    lighhouse-01:
      ansible_host: "{{ lighthouse }}"
      ansible_user: centos
```
6. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
```text
При запуске ошибок нет.
```
7. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```text
Падает с ошибкой из-за отсутствия скаченных дистрибутивов clickhouse

TASK [Install clickhouse packages] *************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.3.44.rpm' found on system"]}

PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=1    ignored=0

```

8. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```text
PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=7    changed=6    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
lighhouse-01               : ok=10   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

```text
PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
lighhouse-01               : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
10. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

```text
Playbook имеет 4 play:
- name: Install Clickhouse
Устанавливает clickhouse на хосте из группы clickhouse:
скачивает дистрибутив (с основного, либо резервного источника данных),
копируется конфиг - для теста настроен интерфейс, который слушает (любой), для теста подключения с внешнего сервера Lighthouse.
создается БД logs (выполнение консольной команды на удаленном сервере: clickhouse-client -q 'create database logs;')

- name: Install Vector 
Устанавливает Vector на хосте из группы vector

- name: Install Nginx
Устанавливает nginx на группе хостов lighthouse:
при помощи пакетного менеджера yum (вcтроенная команда ansible) устанавливает nginx, 
копируется конфиг

- name: Install Lighthouse
Устанавливается Lighthouse на группе хостов lighthouse:
устанавливается git
при помощи git клонируется репозиторий lighthouse в папку nginx

Теги
Для дистрибутивов (скачивание/установка) добавлены tag: distrib
Для конфигураций добавлен tag: config  
```

11. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.