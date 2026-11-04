#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-platform-local}"

if kind get clusters | grep -qx "$NAME"; then
  echo "STILL PRESENT: kind cluster $NAME"
  exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -qx "platform-local-floci"; then
  echo "STILL PRESENT: emulator container platform-local-floci"
  exit 1
fi

echo "clean: no $NAME kind cluster and no emulator container"
