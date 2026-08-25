# ADR-0004: Decoupled Module Consumption Model

## Status

Accepted

## Context

As the CCoE, we need to provide reusable infrastructure components to autonomous product teams while maintaining:

- Clear separation of concerns between CCoE (module provider) and product teams (consumers)
- Independent deployment lifecycles for each team
- Centralized guardrails without centralized bottlenecks
- Scalability as the number of product teams grows

The current model where teams clone/fork the landing zone repository creates:

- Version drift between teams
- Difficulty in rolling out module updates
- Confusion about what teams should modify vs. consume as-is

## Decision

We adopt a **decoupled consumption model** with the following separation:

### CCoE Responsibilities (this repository)

| Artifact | Description | Delivery Mechanism |
|----------|-------------|-------------------|
| Terraform Modules | Reusable, versioned infrastructure components | Private Terraform Registry (or Git tags) |
| Reusable Workflows | CI/CD pipeline templates for plan/apply | GitHub Actions `workflow_call` |
| Policy Rules | Conftest/Checkov policies | Published as versioned artifacts |
| SCPs | Organization-wide guardrails | Applied via landing-zone-org module |
| Documentation | Module usage guides, ADRs | This repository's docs/ folder |

### Product Team Responsibilities (their own repositories)

| Artifact | Description | Source |
|----------|-------------|--------|
| Root Configurations | Thin Terraform configs that call CCoE modules | Team-owned repo |
| Variable Values | Environment-specific tfvars | Team-owned repo |
| State Backend | S3 bucket + DynamoDB table per team/account | Bootstrap module |
| Pipeline Execution | Runs CCoE-provided reusable workflows | Team's `.github/workflows/` |
| Secrets/Credentials | AWS IAM roles for pipeline | Team-managed (with CCoE-provided IAM module) |

### Module Consumption Pattern

Product teams consume modules via registry or Git tags, never relative paths:

```hcl
# Using Terraform Registry (preferred)
module "vpc" {
  source  = "app.terraform.io/your-org/network-vpc/aws"
  version = "~> 1.2.0"
  # ...
}

# Using Git tags (alternative)
module "vpc" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/network-vpc?ref=v1.2.0"
  # ...
}
```

### Pipeline Consumption Pattern

Product teams create thin workflow files that call CCoE reusable workflows:

```yaml
# .github/workflows/terraform.yml in product team repo
name: Terraform
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  plan:
    if: github.event_name == 'pull_request'
    uses: your-org/aws-landing-zone/.github/workflows/reusable-terraform-plan.yml@v1
    with:
      working_directory: "environments/prod"
    secrets: inherit

  apply:
    if: github.event_name == 'push'
    uses: your-org/aws-landing-zone/.github/workflows/reusable-terraform-apply.yml@v1
    with:
      working_directory: "environments/prod"
    secrets: inherit
```

### State Isolation

Each product team bootstraps their own state infrastructure:

```
team-a-terraform-state/
├── team-a-app-prod/terraform.tfstate
├── team-a-app-staging/terraform.tfstate
└── team-a-shared/terraform.tfstate

team-b-terraform-state/
├── team-b-service-prod/terraform.tfstate
└── team-b-service-dev/terraform.tfstate
```

## Consequences

### Positive

- **Clear ownership**: CCoE owns modules, product teams own deployments
- **Independent velocity**: Teams upgrade module versions at their own pace
- **Scalability**: No central bottleneck for approving team deployments
- **Version control**: Explicit module versions in team configs
- **Auditability**: Each team's state is isolated and auditable
- **Guardrails without gates**: SCPs and policies enforce compliance without blocking PRs

### Negative

- **Initial setup overhead**: Each team must bootstrap state infrastructure
- **Registry maintenance**: CCoE must maintain and version the registry
- **Policy distribution**: Teams must reference correct policy versions
- **Drift potential**: Teams on old module versions may miss security fixes

### Mitigations

| Risk | Mitigation |
|------|------------|
| Teams on old versions | Automated PR creation via Dependabot/Renovate for module updates |
| State bootstrap complexity | Provide `state-bootstrap` module and clear documentation |
| Registry availability | Use Git-based fallback (tags), or registry replication |
| Policy version drift | Version policies alongside modules, enforce minimum version via SCP |

## Implementation

1. Publish modules to Terraform Registry with semantic versioning
2. Create `reusable-terraform-plan.yml` and `reusable-terraform-apply.yml` as `workflow_call` workflows
3. Create `product-team-template/` as a starter template for teams
4. Create `modules/state-bootstrap/` for team state infrastructure
5. Update all existing modules to remove any hardcoded values
6. Document the consumption model in `docs/consumption-guide.md`
