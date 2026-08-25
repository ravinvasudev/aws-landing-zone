# ------------------------------------------------------------------------------
# Landing Zone Organization Module - Outputs
# ------------------------------------------------------------------------------

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = null # TODO: Replace with aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = null # TODO: Replace with aws_organizations_organization.this.arn
}

output "root_id" {
  description = "The ID of the organization root"
  value       = null # TODO: Replace with aws_organizations_organization.this.roots[0].id
}

output "organizational_unit_ids" {
  description = "Map of OU names to their IDs"
  value       = {} # TODO: Replace with actual OU ID map
}

output "scp_ids" {
  description = "Map of SCP names to their IDs"
  value       = {} # TODO: Replace with actual SCP ID map
}

output "management_account_id" {
  description = "The AWS account ID of the management account"
  value       = null # TODO: Replace with aws_organizations_organization.this.master_account_id
}
