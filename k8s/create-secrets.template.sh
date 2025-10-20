#!/bin/bash
# Template for creating Kubernetes secrets
# Copy this to create-secrets.sh and fill in your actual values

# INSTRUCTIONS:
# 1. Copy this file: cp create-secrets.template.sh create-secrets.sh
# 2. Edit create-secrets.sh and replace placeholder values
# 3. Run: chmod +x k8s/create-secrets.sh
# 4. Run: ./k8s/create-secrets.sh

# TODO: Replace with your actual Rails master key from config/master.key
RAILS_MASTER_KEY="YOUR_RAILS_MASTER_KEY_HERE"

# TODO: Replace with your actual database password
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"

# Create the secret in Kubernetes
kubectl create secret generic rails-secret \
  --from-literal=RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" \
  --from-literal=DB_PASSWORD="${DB_PASSWORD}" \
  --namespace=eviction-meditation \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✓ Secret created successfully!"
echo "Now you can deploy with: kubectl apply -f k8s/rails-deployment.yaml"
