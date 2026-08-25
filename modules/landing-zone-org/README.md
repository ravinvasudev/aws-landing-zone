# Landing Zone Organization Module

Manages the AWS Organizations structure including organizational units (OUs), service control policies (SCPs), and delegated administrator assignments.

## Features

- AWS Organizations setup with all features enabled
- Hierarchical OU structure (Security, Infrastructure, Workloads, Sandbox, Suspended)
- Service Control Policy management
- AWS service principal integrations
- Tag policies and backup policies support

## Usage

```hcl
module "landing_zone_org" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/landing-zone-org?ref=v1.0.0"

  organizational_units = {
    "Security" = {
      description = "Security and audit accounts"
    }
    "Infrastructure" = {
      description = "Shared infrastructure accounts"
    }
    "Workloads" = {
      description = "Product team workload accounts"
    }
    "Workloads/Production" = {
      parent_ou   = "Workloads"
      description = "Production workload accounts"
    }
    "Workloads/NonProduction" = {
      parent_ou   = "Workloads"
      description = "Non-production workload accounts"
    }
    "Sandbox" = {
      description = "Developer sandbox accounts"
    }
  }

  service_control_policies = {
    "DenyRootUser" = {
      description = "Deny all actions by root user"
      content     = file("${path.module}/policies/deny-root-user.json")
      target_ous  = ["Workloads", "Sandbox"]
    }
  }

  tags = {
    CostCenter = "platform"
    Owner      = "cloud-platform-team"
  }
}
```

## Default OU Structure

```
Root
├── Security          # Security Hub, Audit, Log Archive accounts
├── Infrastructure    # Shared services, networking, identity
├── Workloads
│   ├── Production    # Prod workload accounts
│   └── NonProduction # Dev/staging workload accounts
├── Sandbox           # Developer experimentation
└── Suspended         # Accounts pending deletion
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0, < 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization_features | Features to enable | `list(string)` | `["ALL"]` | no |
| enabled_policy_types | Policy types to enable | `list(string)` | `["SERVICE_CONTROL_POLICY", "TAG_POLICY", "BACKUP_POLICY"]` | no |
| organizational_units | Map of OUs to create | `map(object)` | See variables.tf | no |
| service_control_policies | Map of SCPs to create | `map(object)` | `{}` | no |
| aws_service_access_principals | Service principals for org integration | `list(string)` | See variables.tf | no |
| tags | Tags for organization resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| organization_id | The ID of the AWS Organization |
| organization_arn | The ARN of the AWS Organization |
| root_id | The ID of the organization root |
| organizational_unit_ids | Map of OU names to their IDs |
| scp_ids | Map of SCP names to their IDs |
| management_account_id | The management account ID |

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
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | List of AWS service principals to enable for Organizations integration | `list(string)` | <pre>[<br/>  "cloudtrail.amazonaws.com",<br/>  "config.amazonaws.com",<br/>  "guardduty.amazonaws.com",<br/>  "securityhub.amazonaws.com",<br/>  "sso.amazonaws.com",<br/>  "tagpolicies.tag.amazonaws.com",<br/>  "reporting.trustedadvisor.amazonaws.com"<br/>]</pre> | no |
| <a name="input_enabled_policy_types"></a> [enabled\_policy\_types](#input\_enabled\_policy\_types) | List of policy types to enable in the organization | `list(string)` | <pre>[<br/>  "SERVICE_CONTROL_POLICY",<br/>  "TAG_POLICY",<br/>  "BACKUP_POLICY"<br/>]</pre> | no |
| <a name="input_organization_features"></a> [organization\_features](#input\_organization\_features) | List of AWS Organizations features to enable | `list(string)` | <pre>[<br/>  "ALL"<br/>]</pre> | no |
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | Map of organizational units to create | <pre>map(object({<br/>    parent_ou   = optional(string, "root")<br/>    description = optional(string, "")<br/>  }))</pre> | <pre>{<br/>  "Infrastructure": {<br/>    "description": "Shared infrastructure accounts"<br/>  },<br/>  "Sandbox": {<br/>    "description": "Developer sandbox accounts"<br/>  },<br/>  "Security": {<br/>    "description": "Security and audit accounts"<br/>  },<br/>  "Suspended": {<br/>    "description": "Accounts pending deletion"<br/>  },<br/>  "Workloads": {<br/>    "description": "Product team workload accounts"<br/>  },<br/>  "Workloads/NonProduction": {<br/>    "description": "Non-production workload accounts",<br/>    "parent_ou": "Workloads"<br/>  },<br/>  "Workloads/Production": {<br/>    "description": "Production workload accounts",<br/>    "parent_ou": "Workloads"<br/>  }<br/>}</pre> | no |
| <a name="input_service_control_policies"></a> [service\_control\_policies](#input\_service\_control\_policies) | Map of SCPs to create and attach | <pre>map(object({<br/>    description = string<br/>    content     = string<br/>    target_ous  = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to organization resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_account_id"></a> [management\_account\_id](#output\_management\_account\_id) | The AWS account ID of the management account |
| <a name="output_organization_arn"></a> [organization\_arn](#output\_organization\_arn) | The ARN of the AWS Organization |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | The ID of the AWS Organization |
| <a name="output_organizational_unit_ids"></a> [organizational\_unit\_ids](#output\_organizational\_unit\_ids) | Map of OU names to their IDs |
| <a name="output_root_id"></a> [root\_id](#output\_root\_id) | The ID of the organization root |
| <a name="output_scp_ids"></a> [scp\_ids](#output\_scp\_ids) | Map of SCP names to their IDs |
<!-- END_TF_DOCS -->