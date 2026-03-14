terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "devops-olya"
    region = "ru-central1"
    key    = "terraform/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # необходимая опция при описании бэкенда для Terraform версии 1.6.1 и старше.
    skip_s3_checksum            = true # необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  }
}

variable "yc_cloud_id" {}
variable "yc_folder_id" {}
variable "ssh_public_key_content" {}

provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-b"
}

resource "yandex_vpc_network" "default" {
  name = "tf-network"
}

resource "yandex_vpc_subnet" "default" {
  name           = "tf-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_security_group" "ssh_allow" {
  name        = "allow-ssh-sg"
  network_id  = yandex_vpc_network.default.id
  description = "Разрешить входящий SSH (порт 22)"

  ingress {
    protocol       = "TCP"
    description    = "SSH Access"
    port           = 22
    v4_cidr_blocks    = ["0.0.0.0/0"] 
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks    = ["0.0.0.0/0"] 
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "wines-rag-vm"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.ssh_allow.id]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = "network-hdd"
      size     = 9
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key_content}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg
        - lsb-release
      runcmd:
        - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        - apt-get update
        - apt-get install -y docker-ce docker-ce-cli containerd.io
        - usermod -aG docker ubuntu
        - sudo service docker start
      EOF
  }
}

output "external_ip" {
  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}