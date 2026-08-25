# ------------------------------------------------------------------------------
# Landing Zone Organization Module - Variables
# ------------------------------------------------------------------------------

variable "organization_features" {
  description = "List of AWS Organizations features to enable"
  type        = list(string)
  default     = ["ALL"]

  validation {
    condition     = contains(["ALL", "CONSOLIDATED_BILLING"], var.organization_features[0])
    error_message = "Organization features must be either ALL or CONSOLIDATED_BILLING."
  }
}

variable "enabled_policy_types" {
  description = "List of policy types to enable in the organization"
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY", "TAG_POLICY", "BACKUP_POLICY"]
}

variable "organizational_units" {
  description = "Map of organizational units to create"
  type = map(object({
    parent_ou   = optional(string, "root")
    description = optional(string, "")
  }))
  default = {
    "Security" = {
      description = "Security and audit accounts"
    }
    "Infrastructure" = {
      description = "Shared infrastructure accounts"
    }
    "Workloads" = {
      description = "Product team workload accounts"
    }
    "Workloads/Production" = {
      parent_ou   = "Workloads"
      description = "Production workload accounts"
    }
    "Workloads/NonProduction" = {
      parent_ou   = "Workloads"
      description = "Non-production workload accounts"
    }
    "Sandbox" = {
      description = "Developer sandbox accounts"
    }
    "Suspended" = {
      description = "Accounts pending deletion"
    }
  }
}

variable "service_control_policies" {
  description = "Map of SCPs to create and attach"
  type = map(object({
    description = string
    content     = string
    target_ous  = list(string)
  }))
  default = {}
}

variable "aws_service_access_principals" {
  description = "List of AWS service principals to enable for Organizations integration"
  type        = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
    "reporting.trustedadvisor.amazonaws.com"
  ]
}

variable "tags" {
  description = "Tags to apply to organization resources"
  type        = map(string)
  default     = {}
}
