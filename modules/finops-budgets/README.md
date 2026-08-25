# FinOps Budgets Module

Creates AWS Budgets and Cost Anomaly Detection resources to provide visibility and alerting for cloud spend. This module should be wired into every account-vending or resource-provisioning workflow.

## Features

- Monthly cost budgets with configurable limits
- Multiple alert thresholds (50%, 80%, 100%, 120% by default)
- Email notifications via SNS
- AWS Cost Anomaly Detection
- Cost filters by tag, service, or linked account

## Usage

```hcl
module "finops_budget" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/finops-budgets?ref=v1.0.0"

  budget_name         = "workload-prod-monthly"
  budget_limit_amount = 5000

  alert_thresholds = [50, 80, 100, 120]

  alert_email_addresses = [
    "cloud-finops@example.com",
    "team-lead@example.com"
  ]

  cost_filters = {
    TagKeyValue = ["user:CostCenter$platform"]
  }

  enable_anomaly_detection     = true
  anomaly_threshold_percentage = 10

  tags = {
    CostCenter = "platform"
    Owner      = "finops-team"
  }
}
```

## Cost Filters

Common cost filter patterns:

```hcl
# Filter by linked account
cost_filters = {
  LinkedAccount = ["123456789012", "234567890123"]
}

# Filter by service
cost_filters = {
  Service = ["Amazon Elastic Compute Cloud - Compute", "Amazon Simple Storage Service"]
}

# Filter by tag
cost_filters = {
  TagKeyValue = ["user:Environment$prod", "user:Product$customer-api"]
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
| budget_name | Name for the budget | `string` | n/a | yes |
| budget_limit_amount | Monthly budget limit in USD | `number` | n/a | yes |
| budget_type | Type of budget | `string` | `"COST"` | no |
| alert_thresholds | Percentage thresholds for alerts | `list(number)` | `[50, 80, 100, 120]` | no |
| alert_email_addresses | Email addresses for notifications | `list(string)` | `[]` | no |
| cost_filters | Cost filters to scope the budget | `map(list(string))` | `{}` | no |
| enable_anomaly_detection | Enable Cost Anomaly Detection | `bool` | `true` | no |
| anomaly_monitor_type | Type of anomaly monitor | `string` | `"DIMENSIONAL"` | no |
| anomaly_threshold_percentage | Threshold for anomaly alerts | `number` | `10` | no |
| tags | Tags for budget resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| budget_id | The ID of the AWS Budget |
| budget_arn | The ARN of the AWS Budget |
| sns_topic_arn | The ARN of the SNS topic for alerts |
| anomaly_monitor_arn | The ARN of the Cost Anomaly Monitor |
| anomaly_subscription_arn | The ARN of the Cost Anomaly Subscription |

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
| <a name="input_alert_email_addresses"></a> [alert\_email\_addresses](#input\_alert\_email\_addresses) | Email addresses to notify when thresholds are breached | `list(string)` | `[]` | no |
| <a name="input_alert_thresholds"></a> [alert\_thresholds](#input\_alert\_thresholds) | List of percentage thresholds that trigger alerts (e.g., [50, 80, 100, 120]) | `list(number)` | <pre>[<br/>  50,<br/>  80,<br/>  100,<br/>  120<br/>]</pre> | no |
| <a name="input_anomaly_monitor_type"></a> [anomaly\_monitor\_type](#input\_anomaly\_monitor\_type) | Type of anomaly monitor (DIMENSIONAL or CUSTOM) | `string` | `"DIMENSIONAL"` | no |
| <a name="input_anomaly_threshold_percentage"></a> [anomaly\_threshold\_percentage](#input\_anomaly\_threshold\_percentage) | Percentage threshold for anomaly alerts | `number` | `10` | no |
| <a name="input_budget_limit_amount"></a> [budget\_limit\_amount](#input\_budget\_limit\_amount) | Monthly budget limit in USD | `number` | n/a | yes |
| <a name="input_budget_name"></a> [budget\_name](#input\_budget\_name) | Name for the budget | `string` | n/a | yes |
| <a name="input_budget_type"></a> [budget\_type](#input\_budget\_type) | Type of budget (COST, USAGE, RI\_UTILIZATION, RI\_COVERAGE, SAVINGS\_PLANS\_UTILIZATION, SAVINGS\_PLANS\_COVERAGE) | `string` | `"COST"` | no |
| <a name="input_cost_filters"></a> [cost\_filters](#input\_cost\_filters) | Cost filters to scope the budget (e.g., by tag, service, or linked account) | `map(list(string))` | `{}` | no |
| <a name="input_enable_anomaly_detection"></a> [enable\_anomaly\_detection](#input\_enable\_anomaly\_detection) | Whether to enable AWS Cost Anomaly Detection | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to budget resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anomaly_monitor_arn"></a> [anomaly\_monitor\_arn](#output\_anomaly\_monitor\_arn) | The ARN of the Cost Anomaly Monitor |
| <a name="output_anomaly_subscription_arn"></a> [anomaly\_subscription\_arn](#output\_anomaly\_subscription\_arn) | The ARN of the Cost Anomaly Subscription |
| <a name="output_budget_arn"></a> [budget\_arn](#output\_budget\_arn) | The ARN of the AWS Budget |
| <a name="output_budget_id"></a> [budget\_id](#output\_budget\_id) | The ID of the AWS Budget |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic for budget alerts |
<!-- END_TF_DOCS -->