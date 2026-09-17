#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up resources..."
helm uninstall vector --namespace vector || true
kubectl delete namespace vector --ignore-not-found
kubectl delete -f manifests/01-ecommerce-apps.yaml --ignore-not-found
kubectl delete -f manifests/02-zincsearch.yaml --ignore-not-found
echo "Cleanup completed successfully."