terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "1.3.2"
}

provider "yandex" {
    zone = "ru-central1-a"
}
