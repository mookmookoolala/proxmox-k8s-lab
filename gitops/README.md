# GitOps with Argo CD

This directory is the desired state for the `homelab` cluster. Argo CD reads the
public repository over HTTPS, so no Git credential is stored in the cluster.

Argo CD is pinned to v3.5.6 in the bootstrap script. Review release notes and test
upgrades before changing that version.

## Layout

```text
gitops/
├── applications/              # Application workloads
├── bootstrap/                 # Root Argo CD Application
├── clusters/homelab/          # What the homelab cluster reconciles
└── infrastructure/            # Shared namespaces and platform components
```

The initial example manages only a `workloads` namespace. Add applications under
`applications/` and infrastructure such as ingress, storage, and monitoring
under `infrastructure/`, then reference their Kustomizations from the relevant
parent `kustomization.yaml`.

## Prerequisites

- A working cluster with a CNI installed
- `kubectl` configured for the cluster
- This GitOps directory committed and pushed to the repository's `main` branch

Verify the context before making any cluster change:

```bash
kubectl config current-context
kubectl get nodes
```

## Bootstrap

The script refuses to run unless the expected context is supplied explicitly:

```bash
export CONFIRM_CONTEXT="$(kubectl config current-context)"
./gitops/bootstrap-argocd.sh
```

If Argo CD is not already installed, the script installs the pinned upstream
non-HA manifest. If the Argo CD Application CRD already exists, installation is
skipped and your existing deployment is preserved. The script then applies the
root Application. It does not create or request a GitHub token.

Check reconciliation:

```bash
kubectl get applications -n argocd
kubectl get namespace workloads
```

## Secrets

Never commit a plaintext Kubernetes `Secret`, kubeconfig, bootstrap token,
private key, or decrypted SOPS file. For secrets, use SOPS with age or an
external-secrets operator backed by a secret manager.

With SOPS, only the encrypted YAML and age public recipient belong in Git. Keep
the age private key outside the repository and load it into the cluster through
a secure, out-of-band step. Review rendered diffs
before pushing; base64 encoding is not encryption.

## Recovery

Git remains the desired-state record. If Argo CD is reinstalled, run the
bootstrap script again and it will reconnect the cluster. Removing Argo CD or
pruning GitOps resources can delete workloads; inspect changes before merging.
