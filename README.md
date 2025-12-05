# One-Click ALB + ASG + Private EC2 REST API (Terraform)

This repository contains a ready-to-run, one-click Terraform + Node.js example that provisions:
- VPC with 2 public and 2 private subnets
- Internet Gateway + NAT Gateway
- Public Application Load Balancer (ALB) forwarding to a Target Group
- Auto Scaling Group (ASG) of private EC2 instances (no public IPs)
- Minimal IAM Role for SSM and CloudWatch Logs
- A simple Node.js REST API (port 8080) with `/` and `/health`

## Repo layout
```
infra-oneclick/
├─ terraform/
│  ├─ provider.tf
│  ├─ variables.tf
│  ├─ main.tf
│  ├─ outputs.tf
│  └─ userdata.tpl
├─ app/
│  ├─ server.js
│  └─ package.json
├─ scripts/
│  ├─ deploy.sh
│  ├─ destroy.sh
│  └─ test.sh
├─ README.md
└─ .gitignore
```

## Quickstart (one command)
1. Configure AWS credentials (e.g. `aws configure` or export `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`)
2. From repo root:
```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```
3. After deploy finishes note the ALB DNS printed. Test:
```bash
./scripts/test.sh
```
4. Tear down:
```bash
./scripts/destroy.sh
```

## Notes
- Terraform 1.0+ required.
- By default ALB uses HTTP. To enable HTTPS, provide an ACM certificate ARN via the `acm_certificate_arn` variable.
- Instances are configured with SSM (no SSH open). Use Session Manager to access them if needed.

