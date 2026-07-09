#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
HOST=/var/home/panos/Distros/Hermes/workspace/local-cloud

echo ">> tear down"
distrobox-host-exec docker compose -f "$HOST/docker-compose.yml" down -v
distrobox-host-exec bash -c '/tmp/k3d cluster delete local-cloud 2>/dev/null || true'
KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud 2>/dev/null || echo ""') \
  kubectl delete -f hello/deployment.yaml 2>/dev/null || true
echo ">> all down"
