#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/infra/terraform"

cluster_name=${CLUSTER_NAME:-}
aws_region=${AWS_REGION:-}

log() {
  echo "[deploy] $*"
}

if command -v terraform >/dev/null 2>&1; then
  log "Initializing and applying Terraform for the EKS cluster"
  terraform -chdir="$TF_DIR" init -upgrade
  terraform -chdir="$TF_DIR" apply -auto-approve

  cluster_name=$(terraform -chdir="$TF_DIR" output -raw cluster_name)
  aws_region=$(terraform -chdir="$TF_DIR" output -raw aws_region)
else
  log "Terraform not found; assuming cluster already exists. Set CLUSTER_NAME/AWS_REGION if defaults are wrong."
  cluster_name="${cluster_name:-eks-observability-demo}"
  aws_region="${aws_region:-us-west-2}"
fi

log "Updating kubeconfig for cluster ${cluster_name} in ${aws_region}"
aws eks --region "$aws_region" update-kubeconfig --name "$cluster_name"

log "Adding Helm repositories for observability components"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
helm repo update >/dev/null

log "Deploying Prometheus/Grafana"
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace observability --create-namespace \
  -f "$ROOT_DIR/charts/prometheus/values.yaml"

log "Deploying sample frontend + API application"
helm upgrade --install sample-app "$ROOT_DIR/charts/sample-app" \
  --namespace demo --create-namespace

log "Deployment complete. Services:" 
kubectl get svc -A | grep -E "(demo|observability)" || true
