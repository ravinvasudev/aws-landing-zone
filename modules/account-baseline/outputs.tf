# ------------------------------------------------------------------------------
# Account Baseline Module - Outputs
# ------------------------------------------------------------------------------

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = null # TODO: Replace with actual resource reference
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = null # TODO: Replace with actual resource reference
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail (if enabled)"
  value       = null # TODO: Replace with actual resource reference
}

output "permission_boundary_arn" {
  description = "The ARN of the permission boundary applied to this account"
  value       = var.permission_boundary_arn
}
