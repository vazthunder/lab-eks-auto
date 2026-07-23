#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT="${LOCAL_PORT:-8443}"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name> <instance-id> [region]

Start an SSM tunnel to reach a private-only EKS cluster endpoint.

Args:
  cluster-name   EKS cluster name (required)
  instance-id    EC2 instance ID in the VPC with SSM agent (required)
  region         AWS region (default: us-east-2)

Env:
  LOCAL_PORT     Local port for the tunnel (default: 8443)
EOF
  exit 1
}

cleanup() {
  echo ""
  echo "Shutting down tunnel..."
  if [[ -n "${TUNNEL_PID:-}" ]]; then
    kill "$TUNNEL_PID" 2>/dev/null || true
    wait "$TUNNEL_PID" 2>/dev/null || true
  fi
  echo "Done."
}

CLUSTER_NAME="${1:-}"
INSTANCE_ID="${2:-}"
REGION="${3:-us-east-2}"

if [[ -z "$CLUSTER_NAME" ]] || [[ -z "$INSTANCE_ID" ]]; then
  usage
fi

for cmd in aws kubectl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd not found. Install it first." >&2
    exit 1
  fi
done

if lsof -ti:"$LOCAL_PORT" &>/dev/null; then
  echo "Error: port $LOCAL_PORT is already in use. Set LOCAL_PORT to a different port." >&2
  exit 1
fi

echo "Fetching cluster info..."
CLUSTER_JSON=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" 2>&1)
CLUSTER_ENDPOINT=$(echo "$CLUSTER_JSON" | jq -r '.cluster.endpoint')
CLUSTER_VERSION=$(echo "$CLUSTER_JSON" | jq -r '.cluster.version')
CLUSTER_STATUS=$(echo "$CLUSTER_JSON" | jq -r '.cluster.status')
CLUSTER_ARN=$(echo "$CLUSTER_JSON" | jq -r '.cluster.arn')

if [[ -z "$CLUSTER_ENDPOINT" ]] || [[ "$CLUSTER_STATUS" != "ACTIVE" ]]; then
  echo "Error: cluster '$CLUSTER_NAME' not found or not ACTIVE (status: ${CLUSTER_STATUS:-unknown})" >&2
  exit 1
fi

echo "Checking SSM reachability for instance $INSTANCE_ID..."
if ! aws ssm describe-instance-information \
  --filters "Key=instanceIds,Values=$INSTANCE_ID" \
  --region "$REGION" \
  --query 'InstanceInformationList[0]' \
  --output text &>/dev/null; then
  echo "Error: instance $INSTANCE_ID is not registered with SSM or not reachable." >&2
  echo "  Check: SSM agent is running, IAM role has AmazonSSMManagedInstanceCore" >&2
  echo "  Check: instance has outbound connectivity to ssm.<region>.amazonaws.com" >&2
  exit 1
fi

trap cleanup SIGINT SIGTERM EXIT

echo "Starting SSM tunnel on localhost:${LOCAL_PORT} → ${CLUSTER_ENDPOINT} ..."
aws ssm start-session \
  --target "$INSTANCE_ID" \
  --region "$REGION" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{
    \"host\": [\"$(echo "$CLUSTER_ENDPOINT" | sed 's|https://||')\"],
    \"portNumber\": [\"443\"],
    \"localPortNumber\": [\"$LOCAL_PORT\"]
  }" &
TUNNEL_PID=$!

sleep 3

for i in $(seq 1 10); do
  if curl -sk -o /dev/null --connect-timeout 2 "https://localhost:${LOCAL_PORT}" 2>/dev/null; then
    break
  fi
  if ! kill -0 "$TUNNEL_PID" 2>/dev/null; then
    echo "Error: tunnel process exited unexpectedly." >&2
    exit 1
  fi
  sleep 1
done

if ! curl -sk -o /dev/null --connect-timeout 2 "https://localhost:${LOCAL_PORT}" 2>/dev/null; then
  echo "Error: tunnel failed to establish connection." >&2
  exit 1
fi

cat <<EOF

Cluster:    ${CLUSTER_NAME} (${CLUSTER_VERSION})
Endpoint:   ${CLUSTER_ENDPOINT}
Tunnel:     localhost:${LOCAL_PORT} → endpoint via SSM ${INSTANCE_ID}
Status:     ACTIVE (Ctrl+C to stop)

2) Update kubeconfig:
   aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}

3) Point kubectl at the tunnel:
   kubectl config set-cluster "$(echo "$CLUSTER_ARN" | sed 's/:cluster:/:cluster:/')" \
     --server https://localhost:${LOCAL_PORT} \
     --insecure-skip-tls-verify=true

4) Verify:
   kubectl get nodes

EOF

wait "$TUNNEL_PID"
