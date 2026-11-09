# Containerized App on ECS Fargate

## Overview
Build and deploy a containerized sample web service on ECS Fargate behind an Application Load Balancer.

This is an independently uploadable portfolio lab. It is designed to demonstrate infrastructure-as-code practices and a reproducible AWS workflow. It is **not** evidence of a production deployment.

## Architecture
Build and push the image to ECR, then apply Terraform. Running Fargate tasks and an ALB incur ongoing charges.

## Services and skills
Docker, ECR, ECS, Fargate, ALB, Terraform

## Repository layout
```text
.
├── README.md
├── terraform/          # Infrastructure as code
├── docs/               # Architecture and evidence guidance
├── evidence/           # Evidence checklist; add your own screenshots/results
└── .gitignore
```

## Prerequisites
- An AWS account you are authorized to use.
- AWS CLI v2 configured with a dedicated profile.
- Terraform >= 1.6.0.
- Git.
- Review the estimated costs and AWS service quotas before deployment.

## Deploy
```bash
aws sts get-caller-identity --profile YOUR_PROFILE
cd terraform
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
# Review tfplan carefully before applying.
terraform apply tfplan
```

Use a dedicated profile, not root credentials. Never commit credentials, state files, private keys, or plan files. Enable MFA on human access and use short-lived credentials where possible.

## Verify
Follow the project-specific verification steps in `docs/verification.md`. Capture real output from your own account. Do not label a planned deployment, generated code, or a successful local syntax check as a completed AWS deployment.

## Evidence
See `evidence/README.md` and `evidence/evidence-checklist.md`. Replace the placeholders with dated screenshots, command output, resource identifiers (redacted where appropriate), and test results from your own run.

## Cleanup
```bash
cd terraform
terraform destroy
```
Review the destroy plan first. Some services can leave billable resources or retained data behind. Check the AWS Billing console after cleanup.

## Security and cost notes
- Start in a non-production account and a single region.
- Review IAM permissions and network exposure before applying.
- Apply only after reviewing the full Terraform plan.
- This repository intentionally avoids hard-coded credentials and account IDs.
- Costs vary by region, usage, retention, and current AWS pricing. Consult AWS pricing pages before deployment.

## Portfolio disclosure
Suggested wording: "Built as a personal AWS lab using Terraform. Deployment status and evidence are documented in this repository." Only claim resources were deployed if you actually deployed and verified them.

## License
MIT. See `LICENSE`.
