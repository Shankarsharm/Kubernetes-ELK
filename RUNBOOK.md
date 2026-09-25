---

### `RUNBOOK.md` (Step-by-Step Execution Guide)

```markdown
# Deployment & Execution Guide

This guide walks you through deploying the ultra-lightweight logging stack, verifying the data flow, and querying your logs.

## Prerequisites

Ensure you have the following installed and running on your machine:
1. **Docker Desktop** with Kubernetes enabled (or Minikube / K3s).
2. **`kubectl`** CLI configured to communicate with your local cluster.
3. **Helm (v3+)** installed (`helm version`).

---

## Helm Vector repo add and install

    ```bash
    # Install vector helm repo
    helm repo add vector https://helm.vector.dev --force-update
    helm repo update

    # Install helm vector chart with values.yaml
    helm upgrade --install vector vector/vector \
    -f helm/vector-values.yaml \
    --namespace vector \
    --create-namespace
    ```

## Step 1: Deploy the Infrastructure

You can deploy the stack using the provided bash script or manually step-by-step.

### Option A: Using the Deployment Script (Recommended)
Make the script executable and run it:
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
