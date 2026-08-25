# Workload Account Template

Template configuration for product team workload accounts. Copy this folder to create a new workload environment.

## Usage

1. Copy this folder: `cp -r workload-template workloads/my-product-prod`
2. Update `terraform.tfvars` with workload-specific values
3. Configure the backend in `main.tf`
4. Run `terraform init && terraform plan`

## What This Deploys

- Account baseline (GuardDuty, Config, security settings)
- VPC with public, private, and isolated subnets
- NAT Gateways (single in non-prod, per-AZ in prod)
- Budget and cost alerting
- Standard tagging

## Configuration

Create a `terraform.tfvars` file:

```hcl
# Account identification
account_name = "customer-api-prod"
environment  = "prod"

# Tagging (required)
cost_center         = "product-team-a"
owner               = "team-a@example.com"
data_classification = "confidential"
product             = "customer-api"

# Networking
aws_region         = "us-east-1"
vpc_cidr           = "10.100.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnet_cidrs   = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
private_subnet_cidrs  = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]
isolated_subnet_cidrs = ["10.100.21.0/24", "10.100.22.0/24", "10.100.23.0/24"]

# Security
permission_boundary_arn = "arn:aws:iam::111111111111:policy/LandingZoneBoundary"

# FinOps
monthly_budget_limit = 5000
budget_alert_emails  = ["team-a@example.com", "finops@example.com"]
```

## State Management

Each workload account should have its own state file:

```hcl
backend "s3" {
  bucket         = "your-org-terraform-state"
  key            = "workloads/customer-api-prod/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

## Outputs

| Name | Description |
|------|-------------|
| account_id | The AWS account ID |
| vpc_id | The VPC ID |
| private_subnet_ids | Private subnet IDs |
| public_subnet_ids | Public subnet IDs |
| tags | Standard tags map |
