# Kubernetes Deployment Files

## ⚠️ Important: Secrets Management

**NEVER commit secrets to git!**

This directory contains:

### Safe to Commit ✅
- `database-deployment.yaml` - SQL Server deployment config
- `rails-deployment.yaml` - Rails app deployment config (NO SECRETS)
- `create-secrets.template.sh` - Template for creating secrets

### DO NOT Commit ❌
- `create-secrets.sh` - Contains actual secrets (in .gitignore)
- Any file with actual passwords or keys

## How to Handle Secrets Properly

### Step 1: Create Your Secrets Script
```bash
# Copy the template
cp create-secrets.template.sh create-secrets.sh

# Edit create-secrets.sh and add your actual values
```

### Step 2: Run the Script to Create Secrets in Kubernetes
```bash
./create-secrets.sh
```

This creates the `rails-secret` in Kubernetes **without committing it to git**.

### Step 3: Deploy Your Application
```bash
kubectl apply -f database-deployment.yaml
kubectl apply -f rails-deployment.yaml
```

## Why This Approach?

❌ **Bad**: Putting secrets in YAML files that get committed
```yaml
stringData:
  RAILS_MASTER_KEY: "68babbdc5b936240a696xxcfe0a7d531"  # ← This gets committed!
```

✅ **Good**: Creating secrets separately
```bash
kubectl create secret generic rails-secret \
  --from-literal=RAILS_MASTER_KEY="..."  # ← Never committed
```

## Security Best Practices

1. ✅ Keep secrets in `.gitignore`
2. ✅ Use environment variables or secret scripts
3. ✅ Share secrets through password managers (1Password, LastPass)
4. ✅ Rotate secrets regularly
5. ❌ Never commit secrets to git
6. ❌ Never share secrets in Slack/email/chat

## Team Workflow

1. One person creates `create-secrets.sh` from the template
2. Fills in actual secret values
3. Shares the secrets securely (password manager)
4. Each team member creates their own `create-secrets.sh` locally
5. Everyone runs their script to create secrets in Kubernetes
6. The script is never committed (it's in .gitignore)
