# ------------------------------------------------------------------------------
# Management Account - Variables
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "Primary AWS region for the management account"
  type        = string
  default     = "us-east-1"
}

variable "allowed_regions" {
  description = "List of AWS regions where resources can be created"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
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

variable "monthly_budget_limit" {
  description = "Monthly budget limit for the organization in USD"
  type        = number
  default     = 10000
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = []
}
