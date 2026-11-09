#!/usr/bin/env bash
set -euo pipefail
: "${AWS_REGION:=us-east-1}"
: "${ECR_REPOSITORY:=portfolio-ecs-web}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "$ECR_REPOSITORY" --region "$AWS_REGION" >/dev/null
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"
docker build -t "${ECR_REPOSITORY}:latest" ./app
docker tag "${ECR_REPOSITORY}:latest" "${REGISTRY}/${ECR_REPOSITORY}:latest"
docker push "${REGISTRY}/${ECR_REPOSITORY}:latest"
echo "Set container_image=${REGISTRY}/${ECR_REPOSITORY}:latest in terraform.tfvars"
