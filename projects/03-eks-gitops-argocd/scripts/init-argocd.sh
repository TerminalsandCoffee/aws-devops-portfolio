#!/usr/bin/env bash
# Post-deploy helper: configures ArgoCD CLI, registers the repo, and applies the Application CR.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="$PROJECT_DIR/infra/terraform"

echo "=== ArgoCD Init Script ==="
echo ""

# 1. Get ArgoCD initial admin password
echo "[1/5] Retrieving ArgoCD admin password..."
ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
echo "  Admin password: $ARGO_PASSWORD"
echo ""

# 2. Get ArgoCD server URL
echo "[2/5] Getting ArgoCD server URL..."
ARGO_HOST=$(kubectl get svc argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
ARGO_URL="http://${ARGO_HOST}"
echo "  ArgoCD URL: $ARGO_URL"
echo ""

# 3. Login via CLI
echo "[3/5] Logging in to ArgoCD CLI..."
argocd login "$ARGO_HOST" \
  --username admin \
  --password "$ARGO_PASSWORD" \
  --insecure \
  --grpc-web
echo "  Logged in successfully."
echo ""

# 4. Apply the Application CR
echo "[4/5] Applying ArgoCD Application manifest..."
kubectl apply -f "$PROJECT_DIR/argocd/application.yaml"
echo "  Application created."
echo ""

# 5. Check status
echo "[5/5] Checking application sync status..."
argocd app get nginx-demo --grpc-web
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Open ArgoCD UI: $ARGO_URL"
echo "  2. Login: admin / $ARGO_PASSWORD"
echo "  3. Edit files in k8s/ and push — ArgoCD auto-syncs within ~3 minutes"
echo "  4. Watch the sync: argocd app get nginx-demo --watch --grpc-web"
