#!/usr/bin/env bash
set -euo pipefail

PREFIX="${1:?usage: $0 <prefix> <region>}"
REGION="${2:?usage: $0 <prefix> <region>}"

found=0

report() {
  echo "STILL PRESENT: $1"
  echo "$2"
  found=1
}

clusters=$(aws eks list-clusters --region "$REGION" \
  --query "clusters[?starts_with(@, '$PREFIX')]" --output text)
if [ -n "$clusters" ]; then
  report "EKS clusters" "$clusters"
fi

nat=$(aws ec2 describe-nat-gateways --region "$REGION" \
  --filter "Name=tag:Name,Values=$PREFIX-*" \
  --query "NatGateways[?State!='deleted'].NatGatewayId" --output text)
if [ -n "$nat" ]; then
  report "NAT gateways" "$nat"
fi

lbs=$(aws elbv2 describe-load-balancers --region "$REGION" \
  --query "LoadBalancers[?starts_with(LoadBalancerName, '$PREFIX')].LoadBalancerName" --output text)
if [ -n "$lbs" ]; then
  report "load balancers" "$lbs"
fi

if [ "$found" -eq 0 ]; then
  echo "clean: no $PREFIX resources in $REGION"
fi

exit "$found"
