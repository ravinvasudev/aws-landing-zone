# Account Baseline Module

Per-account bootstrap module that establishes the security and compliance baseline for every AWS account in the organization.

## Features

- AWS Config recorder and delivery channel
- GuardDuty detector enrollment
- CloudTrail (optional, for accounts not covered by org trail)
- IAM permission boundary enforcement
- Default EBS encryption
- S3 account-level public access block

## Usage

```hcl
module "account_baseline" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/account-baseline?ref=v1.0.0"

  account_id   = "123456789012"
  account_name = "workload-prod"
  environment  = "prod"

  enable_guardduty  = true
  enable_config     = true
  enable_cloudtrail = false  # Using org trail

  permission_boundary_arn = "arn:aws:iam::123456789012:policy/DefaultBoundary"

  tags = {
    CostCenter = "platform"
    Owner      = "cloud-platform-team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0, < 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | The AWS account ID where the baseline is being applied | `string` | n/a | yes |
| account_name | Human-readable name for the account | `string` | n/a | yes |
| environment | Environment designation (dev, staging, prod, sandbox) | `string` | n/a | yes |
| enable_guardduty | Whether to enable GuardDuty | `bool` | `true` | no |
| enable_config | Whether to enable AWS Config | `bool` | `true` | no |
| enable_cloudtrail | Whether to enable account-level CloudTrail | `bool` | `false` | no |
| permission_boundary_arn | ARN of the IAM permission boundary | `string` | `null` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| config_recorder_id | The ID of the AWS Config recorder |
| guardduty_detector_id | The ID of the GuardDuty detector |
| cloudtrail_arn | The ARN of the CloudTrail trail |
| permission_boundary_arn | The ARN of the permission boundary applied |
