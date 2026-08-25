# ------------------------------------------------------------------------------
# Tagging Module
# Standard tag schema and enforcement policy
# ------------------------------------------------------------------------------

# This module defines and enforces the organization's tagging standard.
# All resources should receive tags through this module's outputs.

locals {
  # Standard required tags that must be present on all taggable resources
  required_tags = {
    CostCenter         = var.cost_center
    Owner              = var.owner
    Environment        = var.environment
    DataClassification = var.data_classification
    Product            = var.product
  }

  # Optional tags that provide additional context
  optional_tags = {
    for k, v in var.additional_tags : k => v if v != null && v != ""
  }

  # Merged tag map ready for use
  tags = merge(
    local.required_tags,
    local.optional_tags,
    {
      ManagedBy = "terraform"
      Blueprint = "aws-landing-zone"
    }
  )
}
