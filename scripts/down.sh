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

echo ">> tear down"
d docker compose -f "$HOST/docker-compose.yml" down -v
d bash -c "$K3D cluster delete local-cloud"
echo ">> all down"