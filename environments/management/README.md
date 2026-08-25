# Management Account Environment

Root configuration for the AWS Organizations management account. This is the foundational deployment that establishes the landing zone structure.

## What This Deploys

- AWS Organizations with OU hierarchy
- Service Control Policies (SCPs)
- IAM permission boundaries
- Organization-wide budget and alerting
- Delegated administrator assignments

## Prerequisites

1. AWS account designated as the management account
2. IAM user or role with Organizations full access
3. S3 bucket and DynamoDB table for Terraform state

## Usage

```bash
# Initialize Terraform
cd environments/management
terraform init

# Review the plan
terraform plan -var-file="terraform.tfvars"

# Apply (requires approval)
terraform apply -var-file="terraform.tfvars"
```

## Configuration

Create a `terraform.tfvars` file:

```hcl
aws_region = "us-east-1"

allowed_regions = ["us-east-1", "us-west-2"]

monthly_budget_limit = 10000

budget_alert_emails = [
  "cloud-finops@example.com"
]
```

## State Management

Configure the backend in `main.tf` before running:

```hcl
backend "s3" {
  bucket         = "your-org-terraform-state"
  key            = "management/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

## Outputs

| Name | Description |
|------|-------------|
| organization_id | The AWS Organization ID |
| organizational_unit_ids | Map of OU names to IDs |
| permission_boundary_arn | The permission boundary ARN |
