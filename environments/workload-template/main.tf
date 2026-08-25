# ------------------------------------------------------------------------------
# Workload Account - Baseline Configuration
# Template for product team workload accounts
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # TODO: Configure remote backend per account
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "workloads/ACCOUNT_NAME/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.tags.tags
  }
}

# ------------------------------------------------------------------------------
# Tagging
# ------------------------------------------------------------------------------

module "tags" {
  source = "../../modules/tagging"

  cost_center         = var.cost_center
  owner               = var.owner
  environment         = var.environment
  data_classification = var.data_classification
  product             = var.product
}

# ------------------------------------------------------------------------------
# Account Baseline
# ------------------------------------------------------------------------------

# TODO: Uncomment when module is fully implemented
# module "account_baseline" {
#   source = "../../modules/account-baseline"
#
#   account_id   = data.aws_caller_identity.current.account_id
#   account_name = var.account_name
#   environment  = var.environment
#
#   enable_guardduty  = true
#   enable_config     = true
#   enable_cloudtrail = false  # Using org trail
#
#   permission_boundary_arn = var.permission_boundary_arn
#
#   tags = module.tags.tags
# }

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------

# TODO: Uncomment when module is fully implemented
# module "vpc" {
#   source = "../../modules/network-vpc"
#
#   vpc_name = "${var.product}-${var.environment}"
#   vpc_cidr = var.vpc_cidr
#
#   availability_zones = var.availability_zones
#
#   public_subnet_cidrs   = var.public_subnet_cidrs
#   private_subnet_cidrs  = var.private_subnet_cidrs
#   isolated_subnet_cidrs = var.isolated_subnet_cidrs
#
#   enable_nat_gateway = var.environment == "prod" ? true : var.enable_nat_gateway
#   single_nat_gateway = var.environment != "prod"
#
#   tags = module.tags.tags
# }

# ------------------------------------------------------------------------------
# FinOps Budgets
# ------------------------------------------------------------------------------

# TODO: Uncomment when module is fully implemented
# module "budget" {
#   source = "../../modules/finops-budgets"
#
#   budget_name         = "${var.product}-${var.environment}-monthly"
#   budget_limit_amount = var.monthly_budget_limit
#
#   alert_email_addresses = var.budget_alert_emails
#
#   cost_filters = {
#     TagKeyValue = ["user:Product$${var.product}"]
#   }
#
#   tags = module.tags.tags
# }

# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
