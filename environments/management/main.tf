# ------------------------------------------------------------------------------
# Management Account - Landing Zone Bootstrap
# This is the root configuration for the AWS Organizations management account
# ------------------------------------------------------------------------------

# This configuration deploys:
# - AWS Organizations structure (OUs and SCPs)
# - Organization-wide CloudTrail
# - Delegated administrator assignments
# - Central logging configuration

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # TODO: Configure remote backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "management/terraform.tfstate"
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

  cost_center         = "platform"
  owner               = "cloud-platform-team"
  environment         = "shared"
  data_classification = "internal"
  product             = "landing-zone"
}

# ------------------------------------------------------------------------------
# AWS Organizations
# ------------------------------------------------------------------------------

# TODO: Uncomment when module is fully implemented
# module "landing_zone_org" {
#   source = "../../modules/landing-zone-org"
#
#   organizational_units = var.organizational_units
#
#   service_control_policies = {
#     "DenyRootUser" = {
#       description = "Deny all actions by root user"
#       content     = file("${path.module}/scps/deny-root-user.json")
#       target_ous  = ["Workloads", "Sandbox"]
#     }
#     "RegionRestriction" = {
#       description = "Restrict to approved regions"
#       content     = module.iam_guardrails.region_restriction_scp
#       target_ous  = ["Workloads"]
#     }
#   }
#
#   tags = module.tags.tags
# }

# ------------------------------------------------------------------------------
# IAM Guardrails
# ------------------------------------------------------------------------------

# TODO: Uncomment when module is fully implemented
# module "iam_guardrails" {
#   source = "../../modules/iam-guardrails"
#
#   permission_boundary_name = "LandingZoneBoundary"
#   allowed_regions          = var.allowed_regions
#
#   tags = module.tags.tags
# }

# ------------------------------------------------------------------------------
# FinOps Budgets
# ------------------------------------------------------------------------------

# TODO: Uncomment when module is fully implemented
# module "org_budget" {
#   source = "../../modules/finops-budgets"
#
#   budget_name         = "organization-monthly"
#   budget_limit_amount = var.monthly_budget_limit
#
#   alert_email_addresses = var.budget_alert_emails
#
#   tags = module.tags.tags
# }
