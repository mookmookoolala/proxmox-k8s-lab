resource "proxmox_virtual_environment_vm" "cluster_node" {
  for_each = var.cluster_nodes

  name        = each.key
  description = "${each.value.role} node managed by Terraform/OpenTofu"
  tags        = concat(var.tags, [each.value.role])

  node_name = var.node_name
  vm_id     = each.value.vm_id

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk_size_gb
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.datastore_id

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = each.value.address
        gateway = var.gateway
      }
    }

    user_account {
      username = var.ssh_username
      keys     = [for key in var.ssh_public_keys : trimspace(key)]
    }
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}

