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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.state_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_bucket.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logging_bucket"></a> [access\_logging\_bucket](#input\_access\_logging\_bucket) | S3 bucket name for access logging. If null, logging is disabled. | `string` | `null` | no |
| <a name="input_create_iam_policy"></a> [create\_iam\_policy](#input\_create\_iam\_policy) | Whether to create an IAM policy for state access. | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encryption. If null, uses AES256 (SSE-S3). | `string` | `null` | no |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | Name of the DynamoDB table for state locking. | `string` | `"terraform-state-lock"` | no |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | Name of the S3 bucket for Terraform state storage. Must be globally unique. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_config"></a> [backend\_config](#output\_backend\_config) | Backend configuration block for use in root modules |
| <a name="output_backend_config_hcl"></a> [backend\_config\_hcl](#output\_backend\_config\_hcl) | Backend configuration as HCL string (for documentation) |
| <a name="output_lock_table_arn"></a> [lock\_table\_arn](#output\_lock\_table\_arn) | ARN of the DynamoDB lock table |
| <a name="output_lock_table_name"></a> [lock\_table\_name](#output\_lock\_table\_name) | Name of the DynamoDB lock table |
| <a name="output_state_access_policy_arn"></a> [state\_access\_policy\_arn](#output\_state\_access\_policy\_arn) | ARN of the IAM policy for state access (if created) |
| <a name="output_state_bucket_arn"></a> [state\_bucket\_arn](#output\_state\_bucket\_arn) | ARN of the S3 bucket for Terraform state |
| <a name="output_state_bucket_name"></a> [state\_bucket\_name](#output\_state\_bucket\_name) | Name of the S3 bucket for Terraform state |
| <a name="output_state_bucket_region"></a> [state\_bucket\_region](#output\_state\_bucket\_region) | Region of the S3 bucket |
<!-- END_TF_DOCS -->