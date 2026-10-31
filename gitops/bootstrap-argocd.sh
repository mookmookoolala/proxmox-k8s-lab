#!/usr/bin/env bash
set -Eeuo pipefail

readonly ARGO_CD_VERSION="v3.5.6"
readonly REPOSITORY_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly ROOT_APPLICATION="${REPOSITORY_ROOT}/gitops/bootstrap/root-application.yaml"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "Required command not found: kubectl" >&2
  exit 1
fi

current_context=$(kubectl config current-context)
if [[ -z ${CONFIRM_CONTEXT:-} || ${CONFIRM_CONTEXT} != "${current_context}" ]]; then
  echo "Refusing to modify Kubernetes context: ${current_context}" >&2
  echo "After verifying it, run: CONFIRM_CONTEXT='${current_context}' $0" >&2
  exit 1
fi

if ! kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply --namespace argocd --server-side --force-conflicts \
    -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGO_CD_VERSION}/manifests/install.yaml"
else
  echo "Existing Argo CD Application CRD found; skipping controller installation."
fi

kubectl apply -f "${ROOT_APPLICATION}"

echo "Argo CD root application applied to context ${current_context}."
echo "Run 'kubectl get applications -n argocd' to watch synchronization."
