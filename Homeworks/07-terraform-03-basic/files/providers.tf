terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.73.0"

#backend "s3" {
#    endpoint   = "storage.yandexcloud.net"
#    bucket     = "backet-ntlg"
#    region     = "ru-central1"
#    key        = "terraform.tfstate"
#    access_key = ""
#    secret_key = ""
#    skip_region_validation      = true
#    skip_credentials_validation = true
#  }
}

#provider "yandex" {
#    token = ""
#    cloud_id  = ""
#    folder_id = ""
#    zone = "ru-central1-a"
#}
