#!/usr/bin/env bash
# Integration test: deploy full stack to Floci, verify outputs, destroy.
# Usage: ./scripts/integration-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PULUMI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXIT_CODE=0

cleanup() {
  echo "=== Cleaning up ==="
  cd "$PULUMI_DIR"
  pulumi destroy --yes 2>/dev/null || true
  docker stop floci 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Integration Test: Pulumi Local Cloud ==="
echo ""

# Step 1: Start Floci
echo ">>> Starting Floci..."
docker run --rm -d --name floci -p 4566:4566 floci/floci:latest
for i in $(seq 1 30); do
  if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "Floci ready."
    break
  fi
  sleep 1
done

# Step 2: Setup Pulumi stack
cd "$PULUMI_DIR"
pulumi stack select dev 2>/dev/null || pulumi stack init dev

# Step 3: Configure Floci endpoints
pulumi config set aws:region us-east-1
pulumi config set aws:accessKey test
pulumi config set aws:secretKey test
pulumi config set aws:skipCredentialsValidation "true"
pulumi config set aws:skipMetadataApiCheck "true"
pulumi config set aws:skipRequestingAccountId "true"

# Step 4: Preview
echo ">>> Preview..."
pulumi preview --diff 2>&1

# Step 5: Deploy
echo ">>> Deploying..."
pulumi up --yes --skip-preview 2>&1

# Step 6: Verify outputs
echo ">>> Verifying outputs..."
OUTPUTS=$(pulumi stack output --json 2>&1)
echo "$OUTPUTS"

# Check for expected outputs
echo "$OUTPUTS" | grep -q "bucketName" || { echo "FAIL: bucketName not found"; EXIT_CODE=1; }
echo "$OUTPUTS" | grep -q "vpcId" || { echo "FAIL: vpcId not found"; EXIT_CODE=1; }
echo "$OUTPUTS" | grep -q "roleName" || { echo "FAIL: roleName not found"; EXIT_CODE=1; }
echo "$OUTPUTS" | grep -q "tableName" || { echo "FAIL: tableName not found"; EXIT_CODE=1; }
echo "$OUTPUTS" | grep -q "clusterName" || { echo "FAIL: clusterName not found"; EXIT_CODE=1; }
echo "$OUTPUTS" | grep -q "repositoryName" || { echo "FAIL: repositoryName not found"; EXIT_CODE=1; }
echo "$OUTPUTS" | grep -q "k8sNamespace" || { echo "FAIL: k8sNamespace not found"; EXIT_CODE=1; }

if [ "$EXIT_CODE" -eq 0 ]; then
  echo ""
  echo "=== ALL INTEGRATION CHECKS PASSED ==="
else
  echo ""
  echo "=== SOME CHECKS FAILED ==="
fi

exit $EXIT_CODE