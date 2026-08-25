# ------------------------------------------------------------------------------
# Development Environment - Variables
# ------------------------------------------------------------------------------

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# Required Tags (enforced by CCoE tagging module)
variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
}

variable "owner" {
  description = "Team or individual responsible for this workload"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "data_classification" {
  description = "Data classification level (public, internal, confidential, restricted)"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Must be one of: public, internal, confidential, restricted."
  }
}

variable "product" {
  description = "Product or application name"
  type        = string
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# FinOps
variable "monthly_budget_usd" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 1000

  validation {
    condition     = var.monthly_budget_usd > 0
    error_message = "Budget must be greater than zero."
  }
}

variable "budget_alert_email" {
  description = "Email address for budget alerts"
  type        = string
}
