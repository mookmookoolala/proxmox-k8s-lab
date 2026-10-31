output "container" {
  description = "Created Tailscale router container identity and configured network."
  value = {
    id           = proxmox_virtual_environment_container.tailscale_router.vm_id
    hostname     = var.hostname
    ipv4_address = var.ipv4_address
  }
}

output "next_steps" {
  description = "One-time bootstrap reminder; Tailscale authentication is intentionally outside Terraform state."
  value       = "Enter CT ${var.container_id}, install Tailscale, advertise 192.168.68.0/24, then approve the route in the Tailscale admin console."
}

