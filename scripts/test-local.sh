#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-platform-local}"

kind get clusters | grep -qx "$NAME"
kubectl --context "kind-$NAME" get nodes | grep -q ' Ready'
kubectl --context "kind-$NAME" -n demo get deploy placeholder | grep -q '1/1'
