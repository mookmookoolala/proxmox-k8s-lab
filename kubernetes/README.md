# Kubernetes bootstrap

These scripts turn the provisioned Debian guests into a small, upstream
Kubernetes cluster. They intentionally keep credentials out of Terraform,
cloud-init, and Git.

## 1. Prepare every node

Run the preparation script on each control-plane and worker VM, selecting the
Kubernetes minor release you want to install. The script installs Debian's
`containerd` package when needed:

```bash
scp kubernetes/prepare-node.sh debian@192.168.68.74:/tmp/
ssh debian@192.168.68.74 \
  'sudo KUBERNETES_MINOR=v1.37 bash /tmp/prepare-node.sh'
```

Repeat for every node. Use the same `KUBERNETES_MINOR` value everywhere. The
script configures kernel modules, networking sysctls, swap, containerd's systemd
cgroup driver, and the Kubernetes APT repository. Review it before running it.

The scripts do not disable the firewall. Permit the ports required by the
Kubernetes components and your selected CNI. At minimum, workers need to
reach the API server on TCP 6443. Refer to the upstream Kubernetes ports and
protocols documentation for the complete role-specific list.

## 2. Initialize the control plane

Choose a Pod CIDR supported by your CNI, then run on the first control-plane
node:

```bash
scp kubernetes/init-control-plane.sh debian@192.168.68.74:/tmp/
ssh debian@192.168.68.74 \
  'sudo bash /tmp/init-control-plane.sh 192.168.68.74 10.244.0.0/16'
```

The script writes the administrator kubeconfig to `/etc/kubernetes/admin.conf`
and also configures it for the invoking sudo user. That file grants powerful
cluster access: do not commit or share it.

## 3. Install a CNI

Install one CNI from its official, versioned installation instructions. Ensure
its configured Pod CIDR matches the value passed to `init-control-plane.sh`.
Do not pipe an unreviewed, floating remote manifest directly into `kubectl`.

Wait until the control-plane node is ready:

```bash
kubectl get nodes --watch
```

## 4. Join workers

On the control-plane node, create a short-lived join command only when needed:

```bash
sudo kubeadm token create --ttl 15m --print-join-command
```

Run the printed command with `sudo` on each prepared worker. Do not save it in a
file, shell script, chat, issue, CI log, or Git history. A bootstrap token is a
secret even though it expires.

Verify the cluster:

```bash
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

## Resetting a lab node

`kubeadm reset` is destructive and does not fully remove CNI networking state.
Only use it on a disposable lab node after reading the command's output and your
CNI's cleanup instructions.
