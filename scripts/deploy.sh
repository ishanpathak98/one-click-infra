#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../terraform"

echo "Initializing Terraform..."
terraform init -input=false

echo "Applying Terraform..."
terraform apply -auto-approve

echo "Done. ALB DNS:"
terraform output -raw alb_dns_name || terraform output alb_dns_name
