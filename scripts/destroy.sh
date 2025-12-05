#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../terraform"

echo "Destroying Terraform-managed infra..."
terraform destroy -auto-approve
echo "Teardown complete."
