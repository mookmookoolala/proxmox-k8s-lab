variable "proxmox_endpoint" {
  description = "Proxmox API endpoint, including port 8006."
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token. Prefer the PROXMOX_VE_API_TOKEN environment variable."
  type        = string
  sensitive   = true
  default     = null
  nullable    = true
}

variable "proxmox_insecure" {
  description = "Allow the default self-signed Proxmox certificate."
  type        = bool
  default     = false
}

variable "node_name" {
  description = "Proxmox node that will host the container."
  type        = string
}

variable "container_id" {
  description = "Unique Proxmox CT ID for the Tailscale router."
  type        = number
  default     = 110
}

variable "hostname" {
  description = "Container and Tailscale hostname."
  type        = string
  default     = "tailscale-router"
}

variable "datastore_id" {
  description = "Storage used for the LXC root filesystem."
  type        = string
  default     = "local-lvm"
}

variable "template_datastore_id" {
  description = "Storage used for downloaded LXC templates."
  type        = string
  default     = "local"
}

variable "network_bridge" {
  description = "Proxmox bridge connected to the home LAN."
  type        = string
  default     = "vmbr0"
}

variable "ipv4_address" {
  description = "LXC IPv4 configuration. Use dhcp initially or a CIDR such as 192.168.68.73/24."
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway. Leave null when using DHCP."
  type        = string
  default     = null
  nullable    = true
}

variable "dns_servers" {
  description = "DNS resolvers configured inside the LXC."
  type        = list(string)
  default     = ["1.1.1.1", "9.9.9.9"]
}

variable "ssh_public_keys" {
  description = "SSH public keys authorized for root inside the LXC."
  type        = list(string)

  validation {
    condition     = length(var.ssh_public_keys) > 0
    error_message = "Provide at least one SSH public key."
  }
}

variable "debian_template_url" {
  description = "Pinned official Proxmox Debian 12 LXC template URL. Integrity is enforced separately with SHA-512."
  type        = string
  default     = "http://download.proxmox.com/images/system/debian-12-standard_12.12-1_amd64.tar.zst"
}

variable "debian_template_file_name" {
  description = "Filename used when storing the downloaded template."
  type        = string
  default     = "debian-12-standard_12.12-1_amd64.tar.zst"
}

variable "debian_template_sha512" {
  description = "SHA-512 checksum published in the official Proxmox appliance metadata."
  type        = string
  default     = "50c85eaaece677a3ebe01cc909b83872e9da2a22c29ae652838afce71e83222fdf40f6accecd7d52b180e912fc1f85ecdf7b3fc4d3027da4d865e509a9e76597"
}
