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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_role_name"></a> [admin\_role\_name](#input\_admin\_role\_name) | Name for the admin role | `string` | `"LandingZoneAdmin"` | no |
| <a name="input_admin_role_trust_arns"></a> [admin\_role\_trust\_arns](#input\_admin\_role\_trust\_arns) | ARNs of principals allowed to assume the admin role | `list(string)` | `[]` | no |
| <a name="input_allowed_regions"></a> [allowed\_regions](#input\_allowed\_regions) | List of AWS regions where resources can be created | `list(string)` | <pre>[<br/>  "us-east-1",<br/>  "us-west-2"<br/>]</pre> | no |
| <a name="input_allowed_services"></a> [allowed\_services](#input\_allowed\_services) | List of AWS services allowed in the permission boundary (empty = all) | `list(string)` | `[]` | no |
| <a name="input_create_admin_role"></a> [create\_admin\_role](#input\_create\_admin\_role) | Whether to create an admin role with permission boundary | `bool` | `true` | no |
| <a name="input_create_readonly_role"></a> [create\_readonly\_role](#input\_create\_readonly\_role) | Whether to create a read-only role | `bool` | `true` | no |
| <a name="input_denied_actions"></a> [denied\_actions](#input\_denied\_actions) | List of IAM actions explicitly denied in the permission boundary | `list(string)` | <pre>[<br/>  "organizations:*",<br/>  "account:*",<br/>  "iam:CreateUser",<br/>  "iam:CreateAccessKey",<br/>  "iam:DeleteAccountPasswordPolicy",<br/>  "iam:UpdateAccountPasswordPolicy"<br/>]</pre> | no |
| <a name="input_password_policy"></a> [password\_policy](#input\_password\_policy) | IAM account password policy settings | <pre>object({<br/>    minimum_password_length        = optional(number, 14)<br/>    require_lowercase_characters   = optional(bool, true)<br/>    require_uppercase_characters   = optional(bool, true)<br/>    require_numbers                = optional(bool, true)<br/>    require_symbols                = optional(bool, true)<br/>    allow_users_to_change_password = optional(bool, true)<br/>    max_password_age               = optional(number, 90)<br/>    password_reuse_prevention      = optional(number, 24)<br/>  })</pre> | `{}` | no |
| <a name="input_permission_boundary_name"></a> [permission\_boundary\_name](#input\_permission\_boundary\_name) | Name for the permission boundary policy | `string` | `"LandingZoneBoundary"` | no |
| <a name="input_readonly_role_name"></a> [readonly\_role\_name](#input\_readonly\_role\_name) | Name for the read-only role | `string` | `"LandingZoneReadOnly"` | no |
| <a name="input_require_mfa_for_console"></a> [require\_mfa\_for\_console](#input\_require\_mfa\_for\_console) | Require MFA for console access | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_role_arn"></a> [admin\_role\_arn](#output\_admin\_role\_arn) | The ARN of the admin role |
| <a name="output_admin_role_name"></a> [admin\_role\_name](#output\_admin\_role\_name) | The name of the admin role |
| <a name="output_deny_root_scp"></a> [deny\_root\_scp](#output\_deny\_root\_scp) | SCP JSON document to deny root user actions |
| <a name="output_permission_boundary_arn"></a> [permission\_boundary\_arn](#output\_permission\_boundary\_arn) | The ARN of the permission boundary policy |
| <a name="output_permission_boundary_name"></a> [permission\_boundary\_name](#output\_permission\_boundary\_name) | The name of the permission boundary policy |
| <a name="output_readonly_role_arn"></a> [readonly\_role\_arn](#output\_readonly\_role\_arn) | The ARN of the read-only role |
| <a name="output_readonly_role_name"></a> [readonly\_role\_name](#output\_readonly\_role\_name) | The name of the read-only role |
| <a name="output_region_restriction_scp"></a> [region\_restriction\_scp](#output\_region\_restriction\_scp) | SCP JSON document for region restriction |
<!-- END_TF_DOCS -->