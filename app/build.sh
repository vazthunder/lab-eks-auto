#!/usr/bin/env bash
set -euo pipefail

ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
REGION="${AWS_DEFAULT_REGION:-us-east-2}"
REPO="${1:-myapp}"
IMAGE="${REPO}:latest"

docker build -t "${IMAGE}" "$(dirname "$0")"

aws ecr get-login-password --region "${REGION}" \
  | docker login --password-stdin --username AWS "${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"

docker tag "${IMAGE}" "${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:latest"
docker push "${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:latest"

echo "---"
echo "Pushed. Update terraform.tfvars with:"
echo "container_image = \"${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:latest\""
