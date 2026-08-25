# ------------------------------------------------------------------------------
# IAM Guardrails Module - Outputs
# ------------------------------------------------------------------------------

output "permission_boundary_arn" {
  description = "The ARN of the permission boundary policy"
  value       = null # TODO: Replace with aws_iam_policy.boundary.arn
}

output "permission_boundary_name" {
  description = "The name of the permission boundary policy"
  value       = var.permission_boundary_name
}

output "admin_role_arn" {
  description = "The ARN of the admin role"
  value       = null # TODO: Replace with aws_iam_role.admin.arn
}

output "admin_role_name" {
  description = "The name of the admin role"
  value       = var.admin_role_name
}

output "readonly_role_arn" {
  description = "The ARN of the read-only role"
  value       = null # TODO: Replace with aws_iam_role.readonly.arn
}

output "readonly_role_name" {
  description = "The name of the read-only role"
  value       = var.readonly_role_name
}

output "region_restriction_scp" {
  description = "SCP JSON document for region restriction"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRegions"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })
}

output "deny_root_scp" {
  description = "SCP JSON document to deny root user actions"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRootUser"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}
