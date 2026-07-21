#!/usr/bin/env bash
set -euo pipefail

# Start Floci AWS emulator for local cloud development.
# Usage: ./scripts/up.sh

echo "Starting Floci..."
docker run --rm -d \
  --name floci \
  -p 4566:4566 \
  -e FLOCI_PORT=4566 \
  floci/floci:latest

echo "Waiting for Floci to be ready..."
for i in $(seq 1 30); do
  if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "Floci is ready!"
    break
  fi
  sleep 1
done

echo "Floci running at http://localhost:4566"