locals {
  vm_instance_count_map = {
    stage = 1
    prod  = 2
  }

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
}


resource "yandex_compute_image" "ubuntu_2004" {
  source_family = "ubuntu-2004-lts"
}
resource "yandex_compute_image" "ubuntu_2204" {
  source_family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm-1-group" {
  count = local.vm_instance_count_map[terraform.workspace]
  name  = format("vm-%02d-%s", count.index + 1, terraform.workspace)

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.ubuntu_2004.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "yandex_compute_instance" "vm-2-group" {

  for_each = local.vm_instance_each_map[terraform.workspace]

  name = each.key
  resources {
    cores  = 2
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = each.value.image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
