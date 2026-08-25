# ------------------------------------------------------------------------------
# Workload Account - Outputs
# ------------------------------------------------------------------------------

output "account_id" {
  description = "The AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "The VPC ID"
  value       = null # TODO: Replace with module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [] # TODO: Replace with module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [] # TODO: Replace with module.vpc.public_subnet_ids
}

output "tags" {
  description = "Standard tags for this workload"
  value       = module.tags.tags
}
