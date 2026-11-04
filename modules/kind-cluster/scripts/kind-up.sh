#!/usr/bin/env bash
set -euo pipefail

NAME="$1"
NODES="$2"
CONFIG="$3"

if kind get clusters 2>/dev/null | grep -qx "$NAME"; then
  exit 0
fi

mkdir -p "$(dirname "$CONFIG")"

{
  printf 'kind: Cluster\n'
  printf 'apiVersion: kind.x-k8s.io/v1alpha4\n'
  printf 'nodes:\n'
  printf '  - role: control-plane\n'
  if [ "$NODES" -gt 1 ]; then
    for _ in $(seq 2 "$NODES"); do
      printf '  - role: worker\n'
    done
  fi
} >"$CONFIG"

kind create cluster --name "$NAME" --config "$CONFIG" --wait 180s
