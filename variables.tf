variable "proxmox_endpoint" {
  description = "Proxmox API endpoint, including port 8006."
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in user@realm!token=secret format. Prefer the PROXMOX_VE_API_TOKEN environment variable."
  type        = string
  sensitive   = true
  default     = null
  nullable    = true
}

variable "proxmox_insecure" {
  description = "Allow a self-signed Proxmox TLS certificate. Replace the certificate and set this to false when possible."
  type        = bool
  default     = false
}

variable "node_name" {
  description = "Target Proxmox node name."
  type        = string
}

variable "template_vm_id" {
  description = "VM ID of an Ubuntu cloud-init template with qemu-guest-agent installed."
  type        = number
}

variable "datastore_id" {
  description = "Proxmox datastore used for VM disks."
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Proxmox bridge connected to the lab network."
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "IPv4 default gateway."
  type        = string
}

variable "dns_servers" {
  description = "DNS servers passed through cloud-init."
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}

variable "ssh_username" {
  description = "Linux account created by cloud-init."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_keys" {
  description = "SSH public keys authorized for the cloud-init account."
  type        = list(string)
  validation {
    condition     = length(var.ssh_public_keys) > 0
    error_message = "Provide at least one SSH public key."
  }
}

variable "cluster_nodes" {
  description = "Kubernetes nodes to create. Addresses must use CIDR notation."
  type = map(object({
    vm_id        = number
    role         = string
    address      = string
    cpu_cores    = number
    memory_mb    = number
    disk_size_gb = number
  }))

  validation {
    condition = alltrue([
      for node in values(var.cluster_nodes) : contains(["control-plane", "worker"], node.role)
    ])
    error_message = "Each node role must be control-plane or worker."
  }

  validation {
    condition     = length([for node in values(var.cluster_nodes) : node if node.role == "control-plane"]) >= 1
    error_message = "Define at least one control-plane node."
  }
}

variable "tags" {
  description = "Tags applied to every VM."
  type        = list(string)
  default     = ["terraform", "kubernetes", "lab"]
}

