# ------------------------------------------------------------------------------
# Management Account - Outputs
# ------------------------------------------------------------------------------

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = null # TODO: Replace with module.landing_zone_org.organization_id
}

output "organizational_unit_ids" {
  description = "Map of OU names to their IDs"
  value       = {} # TODO: Replace with module.landing_zone_org.organizational_unit_ids
}

output "permission_boundary_arn" {
  description = "The ARN of the permission boundary policy"
  value       = null # TODO: Replace with module.iam_guardrails.permission_boundary_arn
}
