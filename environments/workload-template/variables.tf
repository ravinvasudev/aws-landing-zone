# ------------------------------------------------------------------------------
# Workload Account - Variables
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "Primary AWS region for this workload"
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Human-readable name for this account"
  type        = string
}

variable "environment" {
  description = "Environment designation (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "sandbox"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, sandbox."
  }
}

# ------------------------------------------------------------------------------
# Tagging Variables
# ------------------------------------------------------------------------------

variable "cost_center" {
  description = "Cost center code for billing allocation"
  type        = string
}

variable "owner" {
  description = "Team or individual responsible for this workload"
  type        = string
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "product" {
  description = "Product or application name"
  type        = string
}

# ------------------------------------------------------------------------------
# Networking Variables
# ------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "isolated_subnet_cidrs" {
  description = "CIDR blocks for isolated subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways (forced true for prod)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Security Variables
# ------------------------------------------------------------------------------

variable "permission_boundary_arn" {
  description = "ARN of the permission boundary from the management account"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# FinOps Variables
# ------------------------------------------------------------------------------

variable "monthly_budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 1000
}

variable "budget_alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = []
}
