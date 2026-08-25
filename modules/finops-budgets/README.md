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
