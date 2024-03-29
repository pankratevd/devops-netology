# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 


## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
2. Создайте два воркспейса `stage` и `prod`.
3. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
4. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два.

```
в секции locals добавлена map с количеством в зависимости от workspace

  vm_instance_count_map = {
    stage = 1
    prod  = 2
  }

```
5. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.

```
в секции locals добавлена map с описание машин в зависимости от workspace

 vm_instance_each_map = {
    stage = {
      "vm-1-stage" = {
        image  = yandex_compute_image.ubuntu_2004.id,
        memory = 2
      }
    }
    prod = {
      "vm-1-prod" = {
        image  = yandex_compute_image.ubuntu_2004.id,
        memory = 2
      }
      "vm-2-prod" = {
        image  = yandex_compute_image.ubuntu_2204.id,
        memory = 4
      }
    }
  }
```

6. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
7. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.

```
root@srvdck001:/devops-netology/Homeworks/07-terraform-03-basic/files# terraform workspace list
  default
* prod
  stage

```
* Вывод команды `terraform plan` для воркспейса `prod`.  

```
root@srvdck001:/devops-netology/Homeworks/07-terraform-03-basic/files# terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_image.ubuntu_2004 will be created
  + resource "yandex_compute_image" "ubuntu_2004" {
      + created_at      = (known after apply)
      + folder_id       = (known after apply)
      + id              = (known after apply)
      + min_disk_size   = (known after apply)
      + os_type         = (known after apply)
      + pooled          = (known after apply)
      + product_ids     = (known after apply)
      + size            = (known after apply)
      + source_disk     = (known after apply)
      + source_family   = "ubuntu-2004-lts"
      + source_image    = (known after apply)
      + source_snapshot = (known after apply)
      + source_url      = (known after apply)
      + status          = (known after apply)
    }

  # yandex_compute_image.ubuntu_2204 will be created
  + resource "yandex_compute_image" "ubuntu_2204" {
      + created_at      = (known after apply)
      + folder_id       = (known after apply)
      + id              = (known after apply)
      + min_disk_size   = (known after apply)
      + os_type         = (known after apply)
      + pooled          = (known after apply)
      + product_ids     = (known after apply)
      + size            = (known after apply)
      + source_disk     = (known after apply)
      + source_family   = "ubuntu-2204-lts"
      + source_image    = (known after apply)
      + source_snapshot = (known after apply)
      + source_url      = (known after apply)
      + status          = (known after apply)
    }

  # yandex_compute_instance.vm-1-group[0] will be created
  + resource "yandex_compute_instance" "vm-1-group" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUTplDAnzQqrFCCSjF4xxv2reu92faI+ujImcRaaCUbeRc8CbxqpZi2hzk2b47jvoaOpkE9Ubht/3oBbFKugIcNMvo+t34jWsZs4QYvbJj6yEDx4EM2chhKsbvK9V6jn4TKXMosUkx2sU29ijI4NLBfZpEx46fTnaVMufqqXc9JAO8NrByEHs5fvLGExv3jUr/uUvuQtRQOAVeVGjFbN2NRsTaZUgcg9aFsieEcHkBD0MS1ylHwUUXQlt0ggVwtABq43EbePv7QYMLxPBMQ1s6YLyYi54n5Bz7TMnecoHV8Eakr/2nrC73+J5PfZnZsuk4VZSGbQyiuGOqatq4qBC87ATRyJYcjn6yKYmvWf214E2mxoaz9wbrgnRdxx2wNvZm+ia4RKlHTtkM4jZMGbbmsayqRscT6SsFbCvW4nSqGmu5JUvL3ds8LoEssQzwHIPknSz57gcooiGgnn3f/86BysuFhyT3lDTZ6+lxWfxq6ms7KrKPQKmT+PMuQSqNFns= root@srvdck001
            EOT
        }
      + name                      = "vm-01-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = (known after apply)
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-1-group[1] will be created
  + resource "yandex_compute_instance" "vm-1-group" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUTplDAnzQqrFCCSjF4xxv2reu92faI+ujImcRaaCUbeRc8CbxqpZi2hzk2b47jvoaOpkE9Ubht/3oBbFKugIcNMvo+t34jWsZs4QYvbJj6yEDx4EM2chhKsbvK9V6jn4TKXMosUkx2sU29ijI4NLBfZpEx46fTnaVMufqqXc9JAO8NrByEHs5fvLGExv3jUr/uUvuQtRQOAVeVGjFbN2NRsTaZUgcg9aFsieEcHkBD0MS1ylHwUUXQlt0ggVwtABq43EbePv7QYMLxPBMQ1s6YLyYi54n5Bz7TMnecoHV8Eakr/2nrC73+J5PfZnZsuk4VZSGbQyiuGOqatq4qBC87ATRyJYcjn6yKYmvWf214E2mxoaz9wbrgnRdxx2wNvZm+ia4RKlHTtkM4jZMGbbmsayqRscT6SsFbCvW4nSqGmu5JUvL3ds8LoEssQzwHIPknSz57gcooiGgnn3f/86BysuFhyT3lDTZ6+lxWfxq6ms7KrKPQKmT+PMuQSqNFns= root@srvdck001
            EOT
        }
      + name                      = "vm-02-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = (known after apply)
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2-group["vm-1-prod"] will be created
  + resource "yandex_compute_instance" "vm-2-group" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUTplDAnzQqrFCCSjF4xxv2reu92faI+ujImcRaaCUbeRc8CbxqpZi2hzk2b47jvoaOpkE9Ubht/3oBbFKugIcNMvo+t34jWsZs4QYvbJj6yEDx4EM2chhKsbvK9V6jn4TKXMosUkx2sU29ijI4NLBfZpEx46fTnaVMufqqXc9JAO8NrByEHs5fvLGExv3jUr/uUvuQtRQOAVeVGjFbN2NRsTaZUgcg9aFsieEcHkBD0MS1ylHwUUXQlt0ggVwtABq43EbePv7QYMLxPBMQ1s6YLyYi54n5Bz7TMnecoHV8Eakr/2nrC73+J5PfZnZsuk4VZSGbQyiuGOqatq4qBC87ATRyJYcjn6yKYmvWf214E2mxoaz9wbrgnRdxx2wNvZm+ia4RKlHTtkM4jZMGbbmsayqRscT6SsFbCvW4nSqGmu5JUvL3ds8LoEssQzwHIPknSz57gcooiGgnn3f/86BysuFhyT3lDTZ6+lxWfxq6ms7KrKPQKmT+PMuQSqNFns= root@srvdck001
            EOT
        }
      + name                      = "vm-1-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = (known after apply)
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2-group["vm-2-prod"] will be created
  + resource "yandex_compute_instance" "vm-2-group" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUTplDAnzQqrFCCSjF4xxv2reu92faI+ujImcRaaCUbeRc8CbxqpZi2hzk2b47jvoaOpkE9Ubht/3oBbFKugIcNMvo+t34jWsZs4QYvbJj6yEDx4EM2chhKsbvK9V6jn4TKXMosUkx2sU29ijI4NLBfZpEx46fTnaVMufqqXc9JAO8NrByEHs5fvLGExv3jUr/uUvuQtRQOAVeVGjFbN2NRsTaZUgcg9aFsieEcHkBD0MS1ylHwUUXQlt0ggVwtABq43EbePv7QYMLxPBMQ1s6YLyYi54n5Bz7TMnecoHV8Eakr/2nrC73+J5PfZnZsuk4VZSGbQyiuGOqatq4qBC87ATRyJYcjn6yKYmvWf214E2mxoaz9wbrgnRdxx2wNvZm+ia4RKlHTtkM4jZMGbbmsayqRscT6SsFbCvW4nSqGmu5JUvL3ds8LoEssQzwHIPknSz57gcooiGgnn3f/86BysuFhyT3lDTZ6+lxWfxq6ms7KrKPQKmT+PMuQSqNFns= root@srvdck001
            EOT
        }
      + name                      = "vm-2-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = (known after apply)
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 8 to add, 0 to change, 0 to destroy.
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---