#!/usr/bin/env bash
# Post-deploy helper: port-forwards to the ClusterIP Argo CD server and applies the Application CR.
# Does not print the initial admin password.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Argo CD Init Script ==="
echo ""

echo "[1/4] Retrieving Argo CD admin password into a local variable (not printed)..."
ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
echo "  Password retrieved. Rotate this secret after first login; do not log it."
echo ""

echo "[2/4] Port-forwarding argocd-server (ClusterIP) to localhost:8443..."
kubectl -n argocd port-forward svc/argocd-server 8443:443 >/tmp/argocd-port-forward.log 2>&1 &
PF_PID=$!
trap 'kill "$PF_PID" 2>/dev/null || true' EXIT
sleep 3
echo "  UI: https://localhost:8443"
echo ""

echo "[3/4] Logging in to Argo CD CLI via the port-forward..."
argocd login localhost:8443 \
  --username admin \
  --password "$ARGO_PASSWORD" \
  --insecure \
  --grpc-web
unset ARGO_PASSWORD
echo "  Logged in successfully."
echo ""

echo "[4/4] Applying Argo CD Application manifest..."
kubectl apply -f "$PROJECT_DIR/argocd/application.yaml"
echo "  Application created."
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Open https://localhost:8443 (keep this script's port-forward running, or rerun kubectl port-forward)"
echo "  2. Login as admin using: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo "  3. Rotate the initial admin secret and prefer SSO for anything beyond a lab."
echo "  4. Watch the sync: argocd app get nginx-demo --watch --grpc-web"
