#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
HOST=/var/home/panos/Distros/Hermes/workspace/local-cloud

echo ">> compose up (floci + registry)"
distrobox-host-exec docker compose -f "$HOST/docker-compose.yml" up -d

echo ">> k3d cluster create"
distrobox-host-exec bash -c '/tmp/k3d cluster create local-cloud'

echo ">> wait for k3d ready"
for i in $(seq 1 30); do
  KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud') \
    kubectl get nodes --no-headers 2>/dev/null | grep -q Ready && break
  [ $i -eq 30 ] && { echo "FAIL: k3d not ready"; exit 1; }
done

echo ">> wait for compose healthy"
for i in $(seq 1 20); do
  FLOCI=$(distrobox-host-exec docker inspect floci --format '{{.State.Health.Status}}' 2>/dev/null || echo "")
  REG=$(distrobox-host-exec docker inspect local-registry --format '{{.State.Health.Status}}' 2>/dev/null || echo "")
  [[ "$FLOCI" == "healthy" && "$REG" == "healthy" ]] && break
  [ $i -eq 20 ] && { echo "FAIL: compose not healthy"; exit 1; }
done

echo ">> build + push hello to registry"
distrobox-host-exec bash -c 'docker build -t localhost:5000/hello:latest /var/home/panos/Distros/Hermes/workspace/local-cloud/hello/'
distrobox-host-exec docker push localhost:5000/hello:latest

echo ">> import image to k3d"
distrobox-host-exec bash -c '/tmp/k3d image import localhost:5000/hello:latest -c local-cloud'

echo ">> deploy hello pod"
KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud') \
  kubectl apply -f hello/deployment.yaml

echo ">> verify"
curl -sf http://localhost:4566/_localstack/health | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  floci: {len(d[\"services\"])} services')"
curl -sf http://localhost:5000/v2/_catalog | python3 -c "import sys,json; print(f'  registry: {json.load(sys.stdin)}')"
distrobox-host-exec bash -c '/tmp/k3d cluster list'
KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud') kubectl get pods hello

echo ">> all up"
