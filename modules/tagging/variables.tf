# ------------------------------------------------------------------------------
# Tagging Module - Variables
# ------------------------------------------------------------------------------

variable "cost_center" {
  description = "Cost center code for billing allocation"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.cost_center))
    error_message = "Cost center must contain only alphanumeric characters and hyphens."
  }
}

variable "owner" {
  description = "Team or individual responsible for the resource (email or team name)"
  type        = string

  validation {
    condition     = length(var.owner) >= 3 && length(var.owner) <= 100
    error_message = "Owner must be between 3 and 100 characters."
  }
}

variable "environment" {
  description = "Environment designation"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox", "shared"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, sandbox, shared."
  }
}

variable "data_classification" {
  description = "Data classification level for compliance"
  type        = string

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "product" {
  description = "Product or application name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.product))
    error_message = "Product must be lowercase alphanumeric with hyphens only."
  }
}

variable "additional_tags" {
  description = "Additional optional tags to include"
  type        = map(string)
  default     = {}
}
