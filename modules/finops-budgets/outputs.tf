# ------------------------------------------------------------------------------
# FinOps Budgets Module - Outputs
# ------------------------------------------------------------------------------

output "budget_id" {
  description = "The ID of the AWS Budget"
  value       = null # TODO: Replace with aws_budgets_budget.this.id
}

output "budget_arn" {
  description = "The ARN of the AWS Budget"
  value       = null # TODO: Replace with aws_budgets_budget.this.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for budget alerts"
  value       = null # TODO: Replace with aws_sns_topic.budget_alerts.arn
}

output "anomaly_monitor_arn" {
  description = "The ARN of the Cost Anomaly Monitor"
  value       = null # TODO: Replace with aws_ce_anomaly_monitor.this.arn
}

output "anomaly_subscription_arn" {
  description = "The ARN of the Cost Anomaly Subscription"
  value       = null # TODO: Replace with aws_ce_anomaly_subscription.this.arn
}
