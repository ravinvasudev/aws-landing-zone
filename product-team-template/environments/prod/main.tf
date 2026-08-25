# ------------------------------------------------------------------------------
# Production Environment
# Product Team Workload Configuration
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration - update with values from state-bootstrap output
  backend "s3" {
    bucket         = "TEAM_NAME-terraform-state"      # TODO: Update
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TEAM_NAME-terraform-lock"        # TODO: Update
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.tags.tags
  }
}

# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ------------------------------------------------------------------------------
# Tagging (required for all resources)
# ------------------------------------------------------------------------------

module "tags" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/tagging?ref=v1.0.0"

  cost_center         = var.cost_center
  owner               = var.owner
  environment         = var.environment
  data_classification = var.data_classification
  product             = var.product
}

# ------------------------------------------------------------------------------
# Account Baseline (security, compliance)
# ------------------------------------------------------------------------------

module "account_baseline" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/account-baseline?ref=v1.0.0"

  account_id          = data.aws_caller_identity.current.account_id
  account_name        = "${var.product}-${var.environment}"
  environment         = var.environment
  enable_guardduty    = true
  enable_config       = true
  enable_cloudtrail   = false  # Using org trail
  tags                = module.tags.tags
}

# ------------------------------------------------------------------------------
# Networking (VPC) - Production uses HA configuration
# ------------------------------------------------------------------------------

module "vpc" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/network-vpc?ref=v1.0.0"

  vpc_name           = "${var.product}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  # Production: HA NAT gateways
  enable_nat_gateway = true
  single_nat_gateway = false  # One NAT per AZ for HA
  enable_vpn_gateway = false
  enable_flow_logs   = true

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# FinOps (budgets, alerts)
# ------------------------------------------------------------------------------

module "finops" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/finops-budgets?ref=v1.0.0"

  budget_name  = "${var.product}-${var.environment}"
  budget_limit = var.monthly_budget_usd
  cost_center  = var.cost_center
  alert_email  = var.budget_alert_email

  # More aggressive alerting for production
  alert_thresholds = [50, 75, 90, 100]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# Add your workload-specific resources below
# ------------------------------------------------------------------------------
