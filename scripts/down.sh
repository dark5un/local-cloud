#!/usr/bin/env bash
set -euo pipefail
HOST=/var/home/panos/Distros/Hermes/workspace/local-cloud

echo ">> tear down"
distrobox-host-exec docker compose -f "$HOST/docker-compose.yml" down -v
distrobox-host-exec bash -c '/tmp/k3d cluster delete local-cloud'
echo ">> all down"
