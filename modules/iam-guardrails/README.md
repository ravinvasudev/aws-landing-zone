# IAM Guardrails Module

Creates IAM guardrails including permission boundaries, baseline roles, and SCP policy documents for organization-wide enforcement.

## Features

- Permission boundary policy constraining all IAM entities
- Region restriction enforcement
- Denied actions for sensitive operations
- MFA requirement for console access
- IAM account password policy
- Baseline admin and read-only roles
- Pre-built SCP documents for common guardrails

## Usage

```hcl
module "iam_guardrails" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/iam-guardrails?ref=v1.0.0"

  permission_boundary_name = "WorkloadBoundary"

  allowed_regions = ["us-east-1", "us-west-2", "eu-west-1"]

  denied_actions = [
    "organizations:*",
    "account:*",
    "iam:CreateUser",
    "iam:CreateAccessKey"
  ]

  require_mfa_for_console = true

  password_policy = {
    minimum_password_length      = 14
    require_lowercase_characters = true
    require_uppercase_characters = true
    require_numbers              = true
    require_symbols              = true
    max_password_age             = 90
    password_reuse_prevention    = 24
  }

  create_admin_role     = true
  admin_role_name       = "PlatformAdmin"
  admin_role_trust_arns = ["arn:aws:iam::111111111111:root"]

  tags = module.tags.tags
}
```

## Permission Boundary

The permission boundary enforces:

1. **Region restriction**: Actions only allowed in specified regions
2. **Denied actions**: Explicitly blocked sensitive operations
3. **Service restrictions**: Optionally limit to approved services

All IAM roles created by product teams should have this boundary attached.

## SCP Outputs

The module outputs ready-to-use SCP documents:

```hcl
# Attach region restriction SCP to an OU
resource "aws_organizations_policy" "region_restriction" {
  name        = "RegionRestriction"
  description = "Restrict resource creation to approved regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = module.iam_guardrails.region_restriction_scp
}

# Attach deny root SCP to workload OUs
resource "aws_organizations_policy" "deny_root" {
  name        = "DenyRootUser"
  description = "Deny all actions by root user"
  type        = "SERVICE_CONTROL_POLICY"
  content     = module.iam_guardrails.deny_root_scp
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0, < 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| permission_boundary_name | Name for permission boundary | `string` | `"LandingZoneBoundary"` | no |
| allowed_regions | Regions where resources can be created | `list(string)` | `["us-east-1", "us-west-2"]` | no |
| allowed_services | Services allowed (empty = all) | `list(string)` | `[]` | no |
| denied_actions | Actions explicitly denied | `list(string)` | See variables.tf | no |
| require_mfa_for_console | Require MFA for console | `bool` | `true` | no |
| password_policy | IAM password policy settings | `object` | See variables.tf | no |
| create_admin_role | Create admin role | `bool` | `true` | no |
| admin_role_name | Name for admin role | `string` | `"LandingZoneAdmin"` | no |
| admin_role_trust_arns | Principals for admin role | `list(string)` | `[]` | no |
| create_readonly_role | Create read-only role | `bool` | `true` | no |
| readonly_role_name | Name for read-only role | `string` | `"LandingZoneReadOnly"` | no |
| tags | Tags for IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| permission_boundary_arn | Permission boundary policy ARN |
| permission_boundary_name | Permission boundary policy name |
| admin_role_arn | Admin role ARN |
| admin_role_name | Admin role name |
| readonly_role_arn | Read-only role ARN |
| readonly_role_name | Read-only role name |
| region_restriction_scp | SCP JSON for region restriction |
| deny_root_scp | SCP JSON to deny root user |
