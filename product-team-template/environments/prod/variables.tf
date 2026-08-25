# ------------------------------------------------------------------------------
# Production Environment - Variables
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
}

variable "owner" {
  description = "Team or individual responsible for this workload"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "confidential"

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Must be one of: public, internal, confidential, restricted."
  }
}

variable "product" {
  description = "Product or application name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones (minimum 3 for production)"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 3
    error_message = "Production requires at least 3 availability zones."
  }
}

variable "monthly_budget_usd" {
  description = "Monthly budget limit in USD"
  type        = number

  validation {
    condition     = var.monthly_budget_usd > 0
    error_message = "Budget must be greater than zero."
  }
}

variable "budget_alert_email" {
  description = "Email address for budget alerts"
  type        = string
}
