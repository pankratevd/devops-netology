resource "yandex_compute_instance" "ntlg-1-test" {
  name = "ntlg-1-test"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
    image_id = "fd8kb72eo1r5fs97a1ki"
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

