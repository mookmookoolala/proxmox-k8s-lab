#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root (for example, with sudo)." >&2
  exit 1
fi

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <API-server-IP> <Pod-CIDR>" >&2
  exit 1
fi

API_SERVER_IP=$1
POD_CIDR=$2

if [[ ! ${API_SERVER_IP} =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "API-server address must be an IPv4 address." >&2
  exit 1
fi

if [[ ! ${POD_CIDR} =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
  echo "Pod network must be an IPv4 CIDR." >&2
  exit 1
fi

kubeadm init \
  --apiserver-advertise-address="${API_SERVER_IP}" \
  --pod-network-cidr="${POD_CIDR}"

if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
  user_home=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
  install -d -m 0700 -o "${SUDO_USER}" -g "${SUDO_USER}" "${user_home}/.kube"
  install -m 0600 -o "${SUDO_USER}" -g "${SUDO_USER}" \
    /etc/kubernetes/admin.conf "${user_home}/.kube/config"
fi

echo "Control plane initialized. Install a CNI before joining workers."
echo "Generate worker credentials only when needed with:"
echo "  sudo kubeadm token create --ttl 15m --print-join-command"
