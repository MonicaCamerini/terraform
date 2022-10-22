terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.23.0"
    }
  }
}

provider "digitalocean" {
  token = var.token
}

resource "digitalocean_droplet" "jenkins-vm" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins-vm"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.jornada.id]
}

data "digitalocean_ssh_key" "jornada" {
  name = "Jornada"
}

resource "digitalocean_kubernetes_cluster" "kubernetes" {
  name    = "kubernetes"
  region  = var.region
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = ""
}

variable "token" {
  default = ""
}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins-vm.ipv4_address
}

resource "local_file" "name" {
  content = digitalocean_kubernetes_cluster.kubernetes.kube_config.0.raw_config
  filename = "kube_config.yaml"
}