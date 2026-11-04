#!/usr/bin/env bash
set -euo pipefail

PREFIX="${1:?usage: $0 <prefix> <region> [endpoint-url]}"
REGION="${2:?usage: $0 <prefix> <region> [endpoint-url]}"
ENDPOINT="${3:-}"

AWS=(aws --region "$REGION")
if [ -n "$ENDPOINT" ]; then
  AWS+=(--endpoint-url "$ENDPOINT")
fi

found=0

report() {
  echo "STILL PRESENT: $1"
  echo "$2"
  found=1
}

clusters=$("${AWS[@]}" eks list-clusters --query "clusters[?starts_with(@, '$PREFIX')]" --output text)
if [ -n "$clusters" ]; then
  report "EKS clusters" "$clusters"
fi

nat=$("${AWS[@]}" ec2 describe-nat-gateways \
  --filter "Name=tag:Name,Values=$PREFIX-*" \
  --query "NatGateways[?State!='deleted'].NatGatewayId" --output text)
if [ -n "$nat" ]; then
  report "NAT gateways" "$nat"
fi

lbs=$("${AWS[@]}" elbv2 describe-load-balancers \
  --query "LoadBalancers[?starts_with(LoadBalancerName, '$PREFIX')].LoadBalancerName" --output text)
if [ -n "$lbs" ]; then
  report "load balancers" "$lbs"
fi

if [ "$found" -eq 0 ]; then
  echo "clean: no $PREFIX resources in $REGION"
fi

exit "$found"
