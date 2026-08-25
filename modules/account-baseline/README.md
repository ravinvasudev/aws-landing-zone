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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID where the baseline is being applied | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | Human-readable name for the account (used in resource naming) | `string` | n/a | yes |
| <a name="input_enable_cloudtrail"></a> [enable\_cloudtrail](#input\_enable\_cloudtrail) | Whether to enable account-level CloudTrail (set false if using org trail) | `bool` | `false` | no |
| <a name="input_enable_config"></a> [enable\_config](#input\_enable\_config) | Whether to enable AWS Config in this account | `bool` | `true` | no |
| <a name="input_enable_guardduty"></a> [enable\_guardduty](#input\_enable\_guardduty) | Whether to enable GuardDuty in this account | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment designation (dev, staging, prod, sandbox) | `string` | n/a | yes |
| <a name="input_permission_boundary_arn"></a> [permission\_boundary\_arn](#input\_permission\_boundary\_arn) | ARN of the IAM permission boundary to attach to all IAM entities | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | The ARN of the CloudTrail trail (if enabled) |
| <a name="output_config_recorder_id"></a> [config\_recorder\_id](#output\_config\_recorder\_id) | The ID of the AWS Config recorder |
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | The ID of the GuardDuty detector |
| <a name="output_permission_boundary_arn"></a> [permission\_boundary\_arn](#output\_permission\_boundary\_arn) | The ARN of the permission boundary applied to this account |
<!-- END_TF_DOCS -->