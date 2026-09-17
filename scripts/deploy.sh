#!/usr/bin/env bash
set -euo pipefail

echo "Deploying microservices and logging infrastructure..."

# 1. Deploy Apps
kubectl apply -f manifests/01-ecommerce-apps.yaml

# 2. Deploy ZincSearch
kubectl apply -f manifests/02-zincsearch.yaml

# 3. Add and configure Vector via Helm
helm repo add vector https://helm.vector.dev --force-update
helm repo update

helm upgrade --install vector vector/vector \
  -f helm/vector-values.yaml \
  --namespace vector \
  --create-namespace

echo "Waiting for pods to be ready..."
kubectl rollout status deployment/zincsearch -n logging --timeout=120s
kubectl rollout status deployment/order-service -n ecommerce --timeout=60s
kubectl rollout status deployment/payment-service -n ecommerce --timeout=60s

echo "Deployment complete."
echo "Access ZincSearch UI at: http://localhost:30080 (admin / VectorAdmin123!)"