# Proxmox Kubernetes Lab with Terraform/OpenTofu

A reusable infrastructure-as-code starter that clones a Debian cloud-init
template into a small upstream Kubernetes learning cluster on Proxmox VE.

Terraform provisions the virtual machines. The public-safe scripts in
[`kubernetes/`](kubernetes/) then prepare the guests and initialize the cluster
with `containerd` and `kubeadm`. Cluster credentials and join tokens are created
at runtime and are never stored in this repository.

## What it creates

The example creates one control-plane VM and two worker VMs. VM count and sizing
are controlled entirely by the `cluster_nodes` map.

## Prerequisites

- Proxmox VE with a working bridge and enough free VM storage
- OpenTofu 1.6+ or Terraform 1.6+
- A Debian 12 or 13 cloud-init VM template with `cloud-init` and
  `qemu-guest-agent`
  installed and enabled
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

Create the Debian template once using the Proxmox UI or your own audited image
pipeline. Start from an official Debian generic cloud image. The guest should have
`cloud-init`, `qemu-guest-agent`, and `sshd` installed and enabled. Configure a
SCSI disk/controller, VirtIO networking, a cloud-init drive, and a serial
console before converting the VM into a template. Set its VM ID in
`template_vm_id`.

The example creates the `debian` cloud-init user and authorizes an SSH public key.
No console password is configured by default. Connect using SSH after the VM has
booted:

```bash
ssh -i ~/.ssh/id_ed25519 debian@192.168.68.74
```

Before turning a prepared guest into a reusable template, enable its services
and clean the per-instance cloud-init state:

```bash
sudo apt-get update
sudo apt-get install -y cloud-init qemu-guest-agent
sudo systemctl enable cloud-init qemu-guest-agent sshd
sudo cloud-init clean --logs --machine-id
sudo poweroff
```

## Authentication

The provider automatically reads `PROXMOX_VE_API_TOKEN`. The token should be
scoped to the target pool/datastore with only the privileges needed to clone and
configure VMs. `proxmox_insecure = true` is provided for home labs using the
default self-signed certificate; a trusted certificate is preferable.

## Kubernetes setup

After Terraform finishes, follow [`kubernetes/README.md`](kubernetes/README.md).
The setup deliberately leaves CNI selection to the operator because its release
and Pod CIDR must be chosen together. Do not commit `admin.conf`, a kubeconfig,
bootstrap tokens, certificate keys, or generated join commands.

## GitOps

After the cluster and CNI are ready, follow [`gitops/README.md`](gitops/README.md)
to install or connect Argo CD to this public repository. The source is read-only
over HTTPS, so Argo CD does not need a GitHub token or deploy key.

## Safety

- Terraform state may contain infrastructure details; keep it private or use an
  encrypted remote backend.
- Back up existing guests before importing, replacing, or destroying anything.
- Do not reuse VM IDs already present on the Proxmox node.
- Start with `plan`; creation and deletion only occur after an explicit `apply`.
