resource "yandex_compute_instance" "nexus-01" {
  name = "nexus-01"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
    image_id = "fd8hqa9gq1d59afqonsf"
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