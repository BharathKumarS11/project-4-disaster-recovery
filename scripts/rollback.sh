#!/usr/bin/env bash
set -Eeuo pipefail

DEPLOYMENT="${1:-dr-demo}"
NAMESPACE="${2:-default}"

echo "Current rollout history:"
kubectl rollout history "deployment/$DEPLOYMENT" -n "$NAMESPACE"

echo "Rolling back deployment/$DEPLOYMENT..."
kubectl rollout undo "deployment/$DEPLOYMENT" -n "$NAMESPACE"

if kubectl rollout status "deployment/$DEPLOYMENT" \
  -n "$NAMESPACE" --timeout=180s; then
  echo "Rollback completed. Verifying pods..."
  kubectl get pods -n "$NAMESPACE" \
    -l app="$DEPLOYMENT" -o wide
else
  echo "ERROR: Rollback did not become healthy. Investigate the deployment."
  exit 1
fi