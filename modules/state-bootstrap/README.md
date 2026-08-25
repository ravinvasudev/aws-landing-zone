# State Bootstrap Module

This module creates the S3 bucket and DynamoDB table required for Terraform remote state management. It is designed for product teams to bootstrap their own state infrastructure before deploying other resources.

## Features

- S3 bucket with versioning enabled for state recovery
- Server-side encryption (AES256 or KMS)
- Public access blocked
- SSL-only access enforced
- DynamoDB table for state locking with point-in-time recovery
- Optional IAM policy for state access
- Optional access logging

## Usage

### Initial Bootstrap (One-time)

```hcl
# state-bootstrap/main.tf

terraform {
  required_version = ">= 1.5.0"
  
  # Initially uses local state - will migrate to S3 after bucket is created
}

provider "aws" {
  region = "us-east-1"
}

module "state" {
  source  = "app.terraform.io/your-org/state-bootstrap/aws"
  version = "~> 1.0"

  state_bucket_name = "myteam-terraform-state"
  lock_table_name   = "myteam-terraform-lock"

  tags = {
    Team        = "platform"
    CostCenter  = "CLOUD-001"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

output "backend_config" {
  value = module.state.backend_config_hcl
}
```

### Bootstrap Steps

1. **Apply with local state:**
   ```bash
   cd state-bootstrap
   terraform init
   terraform apply
   ```

2. **Note the backend config from output:**
   ```
   backend_config = <<-EOT
     backend "s3" {
       bucket         = "myteam-terraform-state"
       key            = "ENVIRONMENT_NAME/terraform.tfstate"
       region         = "us-east-1"
       dynamodb_table = "myteam-terraform-lock"
       encrypt        = true
     }
   EOT
   ```

3. **(Optional) Migrate bootstrap state to S3:**
   ```hcl
   # Add to state-bootstrap/main.tf
   terraform {
     backend "s3" {
       bucket         = "myteam-terraform-state"
       key            = "bootstrap/terraform.tfstate"
       region         = "us-east-1"
       dynamodb_table = "myteam-terraform-lock"
       encrypt        = true
     }
   }
   ```
   ```bash
   terraform init -migrate-state
   ```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| state_bucket_name | Name of the S3 bucket for Terraform state | `string` | n/a | yes |
| lock_table_name | Name of the DynamoDB table for state locking | `string` | `"terraform-state-lock"` | no |
| kms_key_arn | ARN of KMS key for encryption (null for AES256) | `string` | `null` | no |
| access_logging_bucket | S3 bucket name for access logging | `string` | `null` | no |
| create_iam_policy | Whether to create an IAM policy for state access | `bool` | `true` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| state_bucket_name | Name of the S3 bucket for Terraform state |
| state_bucket_arn | ARN of the S3 bucket |
| state_bucket_region | Region of the S3 bucket |
| lock_table_name | Name of the DynamoDB lock table |
| lock_table_arn | ARN of the DynamoDB lock table |
| state_access_policy_arn | ARN of the IAM policy for state access |
| backend_config | Backend configuration as a map |
| backend_config_hcl | Backend configuration as HCL string |

## Security Considerations

- State bucket has `prevent_destroy` lifecycle - manual removal requires Terraform code change
- Public access is completely blocked
- All access requires HTTPS
- Server-side encryption is mandatory
- DynamoDB has point-in-time recovery enabled

## IAM Requirements

The role/user applying this module needs:

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:CreateBucket",
    "s3:PutBucket*",
    "s3:GetBucket*",
    "dynamodb:CreateTable",
    "dynamodb:DescribeTable",
    "dynamodb:UpdateTable",
    "dynamodb:TagResource",
    "iam:CreatePolicy",
    "iam:GetPolicy"
  ],
  "Resource": "*"
}
```
