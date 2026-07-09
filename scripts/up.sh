#!/usr/bin/env bash
set -euo pipefail

# Portable host-exec wrapper — works with or without distrobox
if command -v distrobox-host-exec &>/dev/null; then
  d() { distrobox-host-exec "$@"; }
else
  d() { "$@"; }
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(cd "$SCRIPT_DIR/.." && pwd)"
K3D="$(command -v k3d || echo "/tmp/k3d")"

echo ">> docker compose up (floci + registry)"
d docker compose -f "$HOST/docker-compose.yml" up -d

echo ">> k3d cluster create"
d bash -c "$K3D cluster create local-cloud"

echo ">> wait for k3d ready"
for i in $(seq 1 30); do
  KUBECONFIG=<(d bash -c "$K3D kubeconfig get local-cloud") \
    kubectl get nodes 2>/dev/null | grep -q Ready && break
  [ "$i" -eq 30 ] && { echo "k3d timeout"; exit 1; }
  sleep 2
done

echo ">> wait for compose health"
for i in $(seq 1 30); do
  floci_ok=$(curl -sf http://localhost:4566/_localstack/health && echo ok || echo no)
  reg_ok=$(curl -sf http://localhost:5000/v2/_catalog && echo ok || echo no)
  [ "$floci_ok" = "ok" ] && [ "$reg_ok" = "ok" ] && break
  [ "$i" -eq 30 ] && { echo "compose timeout"; exit 1; }
  sleep 2
done

echo ">> build + push hello image"
d docker build -t localhost:5000/hello:latest "$HOST/hello/"
d docker push localhost:5000/hello:latest

echo ">> import image to k3d"
d bash -c "$K3D image import localhost:5000/hello:latest -c local-cloud"

echo ">> deploy hello pod"
KUBECONFIG=<(d bash -c "$K3D kubeconfig get local-cloud") \
  kubectl apply -f "$HOST/hello/deployment.yaml"

echo ">> verify"
services=$(curl -sf http://localhost:4566/_localstack/health | grep -o '"services"[^}]*' | grep -o '"[a-z_-]*"' | wc -l)
echo "  floci: $services services"
curl -sf http://localhost:5000/v2/_catalog
KUBECONFIG=<(d bash -c "$K3D kubeconfig get local-cloud") kubectl get pods hello
echo ">> all up"