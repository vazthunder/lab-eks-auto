#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-}"
REGION="${REGION:-us-east-2}"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name> [region]

Update kubeconfig for an EKS cluster with public API access.

Args:
  cluster-name   EKS cluster name (required)
  region         AWS region (default: us-east-2)

Env:
  REGION         AWS region (overrides positional arg default)
EOF
  exit 1
}

if [[ -z "$CLUSTER_NAME" ]]; then
  usage
fi

for cmd in aws kubectl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd not found. Install it first." >&2
    exit 1
  fi
done

aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

echo "kubeconfig updated for cluster '$CLUSTER_NAME' in region '$REGION'"
