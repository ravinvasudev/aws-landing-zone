# ------------------------------------------------------------------------------
# IAM Guardrails Module - Variables
# ------------------------------------------------------------------------------

variable "permission_boundary_name" {
  description = "Name for the permission boundary policy"
  type        = string
  default     = "LandingZoneBoundary"

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]+$", var.permission_boundary_name))
    error_message = "Permission boundary name must match IAM policy naming rules."
  }
}

variable "allowed_regions" {
  description = "List of AWS regions where resources can be created"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]

  validation {
    condition     = length(var.allowed_regions) > 0
    error_message = "At least one region must be allowed."
  }
}

variable "allowed_services" {
  description = "List of AWS services allowed in the permission boundary (empty = all)"
  type        = list(string)
  default     = []
}

variable "denied_actions" {
  description = "List of IAM actions explicitly denied in the permission boundary"
  type        = list(string)
  default = [
    "organizations:*",
    "account:*",
    "iam:CreateUser",
    "iam:CreateAccessKey",
    "iam:DeleteAccountPasswordPolicy",
    "iam:UpdateAccountPasswordPolicy"
  ]
}

variable "require_mfa_for_console" {
  description = "Require MFA for console access"
  type        = bool
  default     = true
}

variable "password_policy" {
  description = "IAM account password policy settings"
  type = object({
    minimum_password_length        = optional(number, 14)
    require_lowercase_characters   = optional(bool, true)
    require_uppercase_characters   = optional(bool, true)
    require_numbers                = optional(bool, true)
    require_symbols                = optional(bool, true)
    allow_users_to_change_password = optional(bool, true)
    max_password_age               = optional(number, 90)
    password_reuse_prevention      = optional(number, 24)
  })
  default = {}
}

variable "create_admin_role" {
  description = "Whether to create an admin role with permission boundary"
  type        = bool
  default     = true
}

variable "admin_role_name" {
  description = "Name for the admin role"
  type        = string
  default     = "LandingZoneAdmin"
}

variable "admin_role_trust_arns" {
  description = "ARNs of principals allowed to assume the admin role"
  type        = list(string)
  default     = []
}

variable "create_readonly_role" {
  description = "Whether to create a read-only role"
  type        = bool
  default     = true
}

variable "readonly_role_name" {
  description = "Name for the read-only role"
  type        = string
  default     = "LandingZoneReadOnly"
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
