#!/usr/bin/env bash
set -euo pipefail

# Deploy the full Pulumi stack against Floci.
# Prerequisites: Floci running (./scripts/up.sh), Pulumi CLI installed.
# Usage: ./scripts/deploy.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PULUMI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PULUMI_DIR"

echo "=== Setting up Pulumi stack ==="
pulumi stack select dev 2>/dev/null || pulumi stack init dev

echo "=== Configuring Floci endpoints ==="
pulumi config set aws:region us-east-1
pulumi config set aws:accessKey test
pulumi config set aws:secretKey test
pulumi config set aws:skipCredentialsValidation "true"
pulumi config set aws:skipMetadataApiCheck "true"
pulumi config set aws:skipRequestingAccountId "true"

echo "=== Previewing infrastructure ==="
pulumi preview

echo ""
echo "=== Deploying infrastructure ==="
pulumi up --yes

echo ""
echo "=== Stack outputs ==="
pulumi stack output

echo ""
echo "=== Deploy complete ==="