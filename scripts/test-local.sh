#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-platform-local}"

kind get clusters | grep -qx "$NAME"
kubectl --context "kind-$NAME" get nodes | grep -q ' Ready'
kubectl --context "kind-$NAME" -n demo get deploy placeholder | grep -q '1/1'
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  aws --endpoint-url http://localhost:4566 iam get-role --role-name gha-github-actions >/dev/null
