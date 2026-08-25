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
