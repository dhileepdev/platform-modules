#!/usr/bin/env bash
set -euo pipefail

NAME="$1"

kind delete cluster --name "$NAME" >/dev/null 2>&1
