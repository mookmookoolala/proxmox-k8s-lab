output "cluster_nodes" {
  description = "Created Kubernetes VM IDs, roles, and configured IP addresses."
  value = {
    for name, vm in proxmox_virtual_environment_vm.cluster_node : name => {
      vm_id   = vm.vm_id
      role    = var.cluster_nodes[name].role
      address = split("/", var.cluster_nodes[name].address)[0]
    }
  }
}

output "ssh_commands" {
  description = "Convenient SSH commands for the created nodes."
  value = {
    for name, node in var.cluster_nodes : name => "ssh ${var.ssh_username}@${split("/", node.address)[0]}"
  }
}

