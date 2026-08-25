# ------------------------------------------------------------------------------
# Tagging Module - Outputs
# ------------------------------------------------------------------------------

output "tags" {
  description = "Complete tag map to apply to resources"
  value       = local.tags
}

output "required_tags" {
  description = "Only the required tags (for validation purposes)"
  value       = local.required_tags
}

output "cost_allocation_tags" {
  description = "Tags used for cost allocation reports"
  value = {
    CostCenter  = var.cost_center
    Environment = var.environment
    Product     = var.product
  }
}

output "tag_policy_document" {
  description = "AWS Organizations tag policy document enforcing the tag schema"
  value = jsonencode({
    tags = {
      CostCenter = {
        tag_key = {
          "@@assign" = "CostCenter"
        }
        enforced_for = {
          "@@assign" = [
            "ec2:instance",
            "ec2:volume",
            "rds:db",
            "s3:bucket",
            "lambda:function"
          ]
        }
      }
      Owner = {
        tag_key = {
          "@@assign" = "Owner"
        }
      }
      Environment = {
        tag_key = {
          "@@assign" = "Environment"
        }
        tag_value = {
          "@@assign" = ["dev", "staging", "prod", "sandbox", "shared"]
        }
      }
      DataClassification = {
        tag_key = {
          "@@assign" = "DataClassification"
        }
        tag_value = {
          "@@assign" = ["public", "internal", "confidential", "restricted"]
        }
      }
      Product = {
        tag_key = {
          "@@assign" = "Product"
        }
      }
    }
  })
}
