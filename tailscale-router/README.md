# Proxmox Tailscale Router LXC

Terraform/OpenTofu configuration for a small, unprivileged Debian 12 LXC that
can act as a Tailscale subnet router for a Proxmox homelab.

## What Terraform creates

- Debian 12 LXC downloaded from the official Proxmox image repository
- CT ID `110` by default
- 1 vCPU, 512 MB RAM, 256 MB swap, and an 8 GB root disk
- DHCP networking on `vmbr0`
- start-at-boot behavior
- nesting enabled through Terraform

Terraform creates infrastructure only. Tailscale authentication is deliberately
performed afterward so an auth key is never stored in Terraform state.

The pinned Proxmox download endpoint currently has a CDN certificate mismatch
for its public alias. This module uses its HTTP endpoint together with the
SHA-512 checksum published in the official `.aplinfo` metadata. Terraform will
reject the download unless its content matches that checksum exactly.

## Plan safely

```bash
cp terraform.tfvars.example terraform.tfvars
# Replace the example SSH public key and review all local values.

export PROXMOX_VE_API_TOKEN='terraform@pve!provider=replace-with-secret'

terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
```

Read the plan. It should create one template download and one LXC. It should not
modify the Kubernetes VMs or any other guest.

Create it only after reviewing the plan:

```bash
terraform apply tfplan
```

Proxmox restricts host-device passthrough to `root@pam`; API tokens cannot
manage this setting. After Terraform creates the container, add the TUN device
once from the Proxmox node shell:

```bash
pct stop 110
pct set 110 --features keyctl=1,nesting=1 --dev0 /dev/net/tun
pct start 110
```

## Bootstrap the container

Enter the new container from the Proxmox node shell:

```bash
pct enter 110
```

Enable packet forwarding so the LXC can route traffic between Tailscale and the
home LAN:

```bash
tee /etc/sysctl.d/99-tailscale.conf >/dev/null <<'EOF'
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl -p /etc/sysctl.d/99-tailscale.conf
```

Install and authenticate Tailscale:

```bash
apt update
apt install -y curl
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up \
  --hostname=tailscale-router \
  --advertise-routes=192.168.68.0/24 \
  --accept-routes=false \
  --accept-dns=false
```

Open the authentication URL, then approve `192.168.68.0/24` under the machine's
route settings in the Tailscale admin console. Remote tailnet devices with
subnet routes enabled can then open Proxmox at `https://192.168.68.71:8006`.

## Security

- Do not commit `terraform.tfvars`, Terraform state, API tokens, or auth keys.
- Do not enable Tailscale Funnel; the subnet should remain tailnet-only.
- Prefer a DHCP reservation before assigning the router LXC a static address.
- Review every destroy plan because destroying this LXC removes remote routing.
