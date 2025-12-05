#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../terraform"
ALB=$(terraform output -raw alb_dns_name 2>/dev/null || true)
if [[ -z "$ALB" ]]; then
  echo "ALB DNS not found. Ensure deployment succeeded or run ./scripts/deploy.sh first."
  exit 1
fi

echo "Testing /health"
curl -sS "http://${ALB}/health" || { echo "Health check failed"; exit 1; }

echo
echo "Testing /"
curl -sS "http://${ALB}/" || { echo "Root check failed"; exit 1; }
echo
echo "Done."
