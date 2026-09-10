# Proxmox Kubernetes Lab with Terraform/OpenTofu

A reusable infrastructure-as-code starter that clones an Ubuntu cloud-init
template into a small upstream Kubernetes learning cluster on Proxmox VE.

The code provisions virtual machines only. Kubernetes installation is kept as a
separate step so users can learn `containerd`, `kubeadm`, CNI installation, and
node joining rather than hiding those operations inside Terraform provisioners.

## What it creates

The example creates one control-plane VM and two worker VMs. VM count and sizing
are controlled entirely by the `cluster_nodes` map.

## Prerequisites

- Proxmox VE with a working bridge and enough free VM storage
- OpenTofu 1.6+ or Terraform 1.6+
- An Ubuntu cloud-init VM template with `qemu-guest-agent` installed
- A least-privilege Proxmox API token
- An SSH public key
- IP addresses reserved outside the DHCP pool

Do not use `root@pam` credentials or commit an API token to this repository.

## Quick start

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars for your network, template, sizing, and SSH key.

export PROXMOX_VE_API_TOKEN='terraform@pve!provider=replace-with-secret'

tofu init
tofu fmt -check
tofu validate
tofu plan -out=tfplan
tofu apply tfplan
```

Use `terraform` instead of `tofu` if preferred. Review every plan before applying
it. Never run an unreviewed destroy plan against a Proxmox host containing data.

## Template requirements

Create the Ubuntu template once using the Proxmox UI or your own audited image
pipeline. It should use a cloud image, SCSI disk/controller, VirtIO networking,
a cloud-init drive, serial console, and QEMU guest agent. Set its VM ID in
`template_vm_id`.

## Authentication

The provider automatically reads `PROXMOX_VE_API_TOKEN`. The token should be
scoped to the target pool/datastore with only the privileges needed to clone and
configure VMs. `proxmox_insecure = true` is provided for home labs using the
default self-signed certificate; a trusted certificate is preferable.

## Next stage

After provisioning, install upstream Kubernetes with `kubeadm` or feed the
output addresses to an Ansible role. This repository intentionally stops before
configuration management.

## Safety

- Terraform state may contain infrastructure details; keep it private or use an
  encrypted remote backend.
- Back up existing guests before importing, replacing, or destroying anything.
- Do not reuse VM IDs already present on the Proxmox node.
- Start with `plan`; creation and deletion only occur after an explicit `apply`.

