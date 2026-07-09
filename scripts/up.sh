#!/usr/bin/env bash
set -euo pipefail
HOST=/var/home/panos/Distros/Hermes/workspace/local-cloud

echo ">> docker compose up (floci + registry)"
distrobox-host-exec docker compose -f "$HOST/docker-compose.yml" up -d

echo ">> k3d cluster create"
distrobox-host-exec bash -c '/tmp/k3d cluster create local-cloud'

echo ">> wait for k3d ready"
for i in $(seq 1 30); do
  KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud') \
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
distrobox-host-exec docker build -t localhost:5000/hello:latest "$HOST/hello/"
distrobox-host-exec docker push localhost:5000/hello:latest

echo ">> import image to k3d"
distrobox-host-exec bash -c "/tmp/k3d image import localhost:5000/hello:latest -c local-cloud"

echo ">> deploy hello pod"
KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud') \
  kubectl apply -f "$HOST/hello/deployment.yaml"

echo ">> verify"
services=$(curl -sf http://localhost:4566/_localstack/health | grep -o '"services"[^}]*' | grep -o '"[a-z_-]*"' | wc -l)
echo "  floci: $services services"
curl -sf http://localhost:5000/v2/_catalog
KUBECONFIG=<(distrobox-host-exec bash -c '/tmp/k3d kubeconfig get local-cloud') kubectl get pods hello
echo ">> all up"
