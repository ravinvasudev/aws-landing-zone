# ------------------------------------------------------------------------------
# Account Baseline Module - Variables
# ------------------------------------------------------------------------------

variable "account_id" {
  description = "The AWS account ID where the baseline is being applied"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Account ID must be a 12-digit number."
  }
}

variable "account_name" {
  description = "Human-readable name for the account (used in resource naming)"
  type        = string

  validation {
    condition     = length(var.account_name) >= 3 && length(var.account_name) <= 50
    error_message = "Account name must be between 3 and 50 characters."
  }
}

variable "environment" {
  description = "Environment designation (dev, staging, prod, sandbox)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, sandbox."
  }
}

variable "enable_guardduty" {
  description = "Whether to enable GuardDuty in this account"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Whether to enable AWS Config in this account"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Whether to enable account-level CloudTrail (set false if using org trail)"
  type        = bool
  default     = false
}

variable "permission_boundary_arn" {
  description = "ARN of the IAM permission boundary to attach to all IAM entities"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
