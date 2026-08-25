# ------------------------------------------------------------------------------
# State Bootstrap - Product Team
# One-time setup for Terraform remote state
# ------------------------------------------------------------------------------
#
# Apply this ONCE manually before setting up environments.
# After applying, note the backend configuration from the output.
#
# Steps:
#   1. cp terraform.tfvars.example terraform.tfvars
#   2. Edit terraform.tfvars with your values
#   3. terraform init
#   4. terraform apply
#   5. Copy backend_config_hcl output to your environment configs
#
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Initially uses local state
  # After first apply, optionally migrate to S3 for state backup
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Team        = var.team_name
      CostCenter  = var.cost_center
      Environment = "shared"
      ManagedBy   = "terraform"
      Purpose     = "terraform-state"
    }
  }
}

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for state infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "team_name" {
  description = "Name of the product team (used in resource naming)"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

# ------------------------------------------------------------------------------
# State Bootstrap Module
# TODO: Update source to your CCoE registry/repository
# ------------------------------------------------------------------------------

module "state" {
  # Option 1: Terraform Registry (preferred)
  # source  = "app.terraform.io/your-org/state-bootstrap/aws"
  # version = "~> 1.0"

  # Option 2: Git reference
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/state-bootstrap?ref=v1.0.0"

  state_bucket_name = "${var.team_name}-terraform-state"
  lock_table_name   = "${var.team_name}-terraform-lock"

  tags = {
    Team       = var.team_name
    CostCenter = var.cost_center
  }
}

# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------

output "state_bucket_name" {
  description = "S3 bucket name for state storage"
  value       = module.state.state_bucket_name
}

output "lock_table_name" {
  description = "DynamoDB table name for state locking"
  value       = module.state.lock_table_name
}

output "backend_config_hcl" {
  description = "Copy this backend config to your environment configurations"
  value       = module.state.backend_config_hcl
}

output "state_access_policy_arn" {
  description = "Attach this policy to your pipeline IAM roles"
  value       = module.state.state_access_policy_arn
}
