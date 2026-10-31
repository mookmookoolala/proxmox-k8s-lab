resource "proxmox_download_file" "debian_12_lxc" {
  content_type       = "vztmpl"
  datastore_id       = var.template_datastore_id
  node_name          = var.node_name
  url                = var.debian_template_url
  file_name          = var.debian_template_file_name
  checksum           = var.debian_template_sha512
  checksum_algorithm = "sha512"
}

resource "proxmox_virtual_environment_container" "tailscale_router" {
  node_name   = var.node_name
  vm_id       = var.container_id
  description = "Tailscale subnet router managed by Terraform/OpenTofu"
  tags        = ["terraform", "tailscale", "network"]

  unprivileged  = true
  start_on_boot = true
  started       = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap      = 256
  }

  disk {
    datastore_id = var.datastore_id
    size         = 8
  }

  operating_system {
    template_file_id = proxmox_download_file.debian_12_lxc.id
    type             = "debian"
  }

  initialization {
    hostname = var.hostname

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    user_account {
      keys = [for key in var.ssh_public_keys : trimspace(key)]
    }
  }

  network_interface {
    name     = "eth0"
    bridge   = var.network_bridge
    firewall = false
  }

  features {
    nesting = true
  }

}
