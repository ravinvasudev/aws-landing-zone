# CCoE Development Guide

This guide is for Cloud Center of Excellence (CCoE) team members who develop, maintain, and release the landing zone modules, policies, and workflows.

## Table of Contents

- [Responsibilities](#responsibilities)
- [Development Workflow](#development-workflow)
- [Module Development](#module-development)
- [Policy Development](#policy-development)
- [SCP Management](#scp-management)
- [Versioning and Releases](#versioning-and-releases)
- [Testing](#testing)
- [Account Vending](#account-vending)
- [Incident Response](#incident-response)

---

## Responsibilities

The CCoE team owns:

| Area | Scope |
|------|-------|
| **Terraform Modules** | Design, development, testing, versioning, documentation |
| **Policies** | Conftest/OPA rules, Checkov custom checks, policy exceptions |
| **SCPs** | Service Control Policies attached to OUs |
| **Reusable Workflows** | GitHub Actions workflows consumed by product teams |
| **Organizations Structure** | OU hierarchy, account vending, baseline deployment |
| **Guardrails** | IAM boundaries, encryption defaults, network restrictions |
| **FinOps** | Budget modules, cost allocation tags, anomaly detection |

The CCoE team does **NOT** own:

- Product team state files
- Product team-specific infrastructure decisions
- Day-to-day operations of workload accounts

---

## Development Workflow

### Branch Strategy

```
main                 # Protected, requires PR review
├── feature/xxx      # New features or modules
├── fix/xxx          # Bug fixes
├── policy/xxx       # Policy changes (extra review required)
└── release/vX.Y.Z   # Release preparation
```

### PR Requirements

| Change Type | Required Reviews | Additional Checks |
|-------------|------------------|-------------------|
| Module code | 1 CCoE member | Terraform validate, fmt, plan |
| Policy changes | 2 CCoE members | Policy tests, impact analysis |
| SCP changes | 2 CCoE members + security | Dry-run on sandbox OU |
| Breaking changes | All CCoE members | Migration guide required |

### Commit Message Convention

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `policy`, `scp`

Examples:
```
feat(network-vpc): add support for IPv6
fix(tagging): correct default tag merge behavior
policy(security): require encryption for EBS volumes
scp(region-restriction): add eu-central-1 to allowed regions
```

---

## Module Development

### Creating a New Module

1. **Create the module directory:**
   ```bash
   mkdir -p modules/my-new-module
   cd modules/my-new-module
   ```

2. **Create required files:**
   ```
   modules/my-new-module/
   ├── main.tf           # Primary resources
   ├── variables.tf      # Input variables with validation
   ├── outputs.tf        # Output values
   ├── versions.tf       # Provider and Terraform version constraints
   ├── README.md         # Generated via terraform-docs
   └── examples/         # Usage examples (optional but recommended)
       └── basic/
           └── main.tf
   ```

3. **Follow these rules:**

### Variable Standards

```hcl
variable "vpc_cidr" {
  description = "CIDR block for the VPC. Must be /16 to /24."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 24
    error_message = "vpc_cidr must be a valid CIDR block between /16 and /24."
  }
}

variable "enable_encryption" {
  description = "Enable encryption at rest. Defaults to true (cannot be disabled in production)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply. Merged with standard CCoE tags."
  type        = map(string)
  default     = {}
}
```

### Resource Naming

```hcl
# Use purpose-based names, not type-based
resource "aws_s3_bucket" "logs" {           # Good
resource "aws_s3_bucket" "s3_bucket" {      # Bad

# Include identifiers for uniqueness
resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-${var.environment}-execution"
}
```

### Tagging Integration

Every module that creates taggable resources must integrate with the tagging module:

```hcl
module "tags" {
  source = "../tagging"

  cost_center         = var.cost_center
  owner               = var.owner
  environment         = var.environment
  data_classification = var.data_classification
  product             = var.product
  additional_tags     = var.tags
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = module.tags.tags
}
```

### Safe Defaults

Modules must default to secure, cost-aware configurations:

```hcl
# Encryption: always on by default
variable "enable_encryption" {
  default = true
}

# Public access: always off by default
variable "enable_public_access" {
  default = false
}

# Instance types: use an allowlist
variable "instance_type" {
  default = "t3.medium"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t3.large"], var.instance_type)
    error_message = "Instance type must be from the approved list."
  }
}
```

### Documentation Generation

```bash
# Install terraform-docs
brew install terraform-docs

# Generate README
terraform-docs markdown table --output-file README.md modules/my-new-module

# Or use pre-commit hook (recommended)
# See .pre-commit-config.yaml
```

---

## Policy Development

See [policies/README.md](../policies/README.md) for running policies locally.

### Conftest (OPA) Policies

Location: `policies/conftest/terraform/`

```rego
# Example: Deny S3 buckets without versioning
package terraform

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.versioning[0].enabled == false
    msg := sprintf("S3 bucket '%s' must have versioning enabled", [resource.address])
}

# Example: Warn on large instance types
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    large_types := {"m5.xlarge", "m5.2xlarge", "c5.xlarge", "c5.2xlarge"}
    resource.change.after.instance_type in large_types
    msg := sprintf("Instance '%s' uses large type '%s'", [resource.address, resource.change.after.instance_type])
}
```

### Checkov Custom Checks

Location: `policies/checkov/custom_checks/`

```python
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories

class RequireVPCFlowLogs(BaseResourceCheck):
    def __init__(self):
        super().__init__(
            name="Ensure VPC has flow logs enabled",
            id="CKV_CUSTOM_001",
            categories=[CheckCategories.LOGGING],
            supported_resources=["aws_vpc"]
        )
    def scan_resource_conf(self, conf):
        return CheckResult.PASSED

check = RequireVPCFlowLogs()
```

### Testing Policies

```bash
conftest verify -p policies/conftest/terraform
conftest test test-fixtures/failing-plan.json -p policies/conftest/terraform/
```

---

## SCP Management

### SCP Lifecycle

```
1. Draft SCP JSON in policies/scps/
2. Test against sandbox OU (attach via Terraform)
3. Review with security team
4. Merge to main
5. Apply to target OU
6. Monitor CloudTrail for denied actions
```

### SCP Structure

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyPublicS3",
      "Effect": "Deny",
      "Action": [
        "s3:PutBucketPublicAccessBlock"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "s3:PublicAccessBlockConfiguration.BlockPublicAcls": "false"
        }
      }
    }
  ]
}
```

### SCP Testing Checklist

- [ ] Test in sandbox account first
- [ ] Verify legitimate actions are not blocked
- [ ] Check for conflicts with existing SCPs
- [ ] Document the business justification
- [ ] Plan rollback procedure
- [ ] Notify affected teams before deployment

### SCP Attachment via Terraform

```hcl
# modules/landing-zone-org/scps.tf
resource "aws_organizations_policy" "deny_public_s3" {
  name        = "deny-public-s3"
  description = "Deny public S3 bucket configurations"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/scps/deny-public-s3.json")
}

resource "aws_organizations_policy_attachment" "deny_public_s3_workloads" {
  policy_id = aws_organizations_policy.deny_public_s3.id
  target_id = aws_organizations_organizational_unit.workloads.id
}
```

---

## Versioning and Releases

### Semantic Versioning

```
vMAJOR.MINOR.PATCH

MAJOR: Breaking changes (variable renames, removed features, behavior changes)
MINOR: New features, new modules, non-breaking additions
PATCH: Bug fixes, documentation updates, security patches
```

### Release Process

1. **Prepare release branch:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b release/v1.2.0
   ```

2. **Update CHANGELOG.md:**
   ```markdown
   ## [1.2.0] - 2026-08-25
   
   ### Added
   - New `network-vpc` output for NAT Gateway IDs
   - Support for IPv6 in VPC module
   
   ### Changed
   - Default instance type updated to t3.medium
   
   ### Fixed
   - Tagging module now correctly merges additional_tags
   
   ### Security
   - Updated minimum TLS version to 1.2
   ```

3. **Run full test suite:**
   ```bash
   make test-all
   # Includes: fmt, validate, policy tests, Terratest
   ```

4. **Create PR and merge:**
   ```bash
   gh pr create --title "Release v1.2.0" --body "See CHANGELOG.md"
   # After approval and merge:
   ```

5. **Tag the release:**
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin v1.2.0
   ```

6. **Publish to registry (if using Terraform Cloud):**
   - Registry auto-detects new tags
   - Verify module appears in registry UI

### Breaking Change Protocol

When introducing breaking changes:

1. **Document in ADR:** Create an ADR explaining the change
2. **Migration guide:** Add to `docs/migrations/v1-to-v2.md`
3. **Deprecation period:** Warn for at least one minor version before removing
4. **Communication:** Notify all product teams via email/Slack

Example deprecation:

```hcl
variable "old_variable_name" {
  description = "DEPRECATED: Use new_variable_name instead. Will be removed in v2.0."
  type        = string
  default     = null
}

locals {
  effective_value = coalesce(var.new_variable_name, var.old_variable_name)
}
```

---

## Testing

### Test Pyramid

```
                    ┌─────────────┐
                    │  E2E Tests  │  ← Terratest (real AWS)
                   ─┴─────────────┴─
                  ┌─────────────────┐
                  │ Integration Tests│  ← Terraform plan + policy
                 ─┴─────────────────┴─
                ┌───────────────────────┐
                │      Unit Tests       │  ← Variable validation, locals
               ─┴───────────────────────┴─
```

### Unit Testing

```bash
# Validate all modules
for dir in modules/*/; do
  echo "Validating $dir"
  terraform -chdir="$dir" init -backend=false
  terraform -chdir="$dir" validate
done

# Check formatting
terraform fmt -check -recursive
```

### Integration Testing

```bash
# Run plan and policy checks
cd environments/workload-template
terraform init
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json

# Run Conftest
conftest test tfplan.json -p ../../policies/conftest/terraform

# Run Checkov
checkov -f tfplan.json --framework terraform_plan
```

### End-to-End Testing (Terratest)

```go
// test/network_vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestNetworkVPC(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/network-vpc/examples/basic",
        Vars: map[string]interface{}{
            "vpc_name": "test-vpc",
            "vpc_cidr": "10.0.0.0/16",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)
}
```

### Running Tests

```bash
# All tests
make test-all

# Specific test suites
make test-unit        # Validate, fmt
make test-policy      # Conftest, Checkov
make test-e2e         # Terratest (requires AWS credentials)
```

---

## Account Vending

Product teams request accounts via GitHub Issues. See the [Consumption Guide](consumption-guide.md#requesting-a-new-account) for the request template.

### CCoE Review Checklist

- [ ] Cost center valid and approved by Finance
- [ ] OU placement appropriate for workload type
- [ ] Budget within team's allocation
- [ ] Owner contact information verified
- [ ] Architecture review completed (for Production OU)

### Provisioning a New Account

```hcl
# environments/workload-{team}-{env}/main.tf
module "account_baseline" {
  source = "../../modules/account-baseline"

  account_name        = "acme-prod"
  account_email       = "aws-acme-prod@example.com"
  organizational_unit = "Workloads/Production"
  
  cost_center = "CC-12345"
  owner       = "acme-team@example.com"
  environment = "production"
  product     = "acme"

  monthly_budget = 5000
  budget_alerts  = ["acme-team@example.com", "finops@example.com"]
}
```

```bash
terraform init && terraform apply
```

### Handoff to Product Team

Provide:
- Account ID
- IAM role ARNs for GitHub Actions
- Link to [Consumption Guide](consumption-guide.md#getting-started)

---

## Incident Response

### SCP Emergency Rollback

If an SCP is blocking legitimate business operations:

1. **Identify the blocking SCP:**
   ```bash
   # Check CloudTrail for Access Denied with SCP
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=EventName,AttributeValue=<operation> \
     --query 'Events[?contains(CloudTrailEvent, `OrganizationPolicies`)]'
   ```

2. **Detach SCP temporarily:**
   ```bash
   # Via CLI (faster than Terraform for emergencies)
   aws organizations detach-policy \
     --policy-id p-xxxxxxxx \
     --target-id ou-xxxx-xxxxxxxx
   ```

3. **Document the incident**

4. **Fix and reattach via Terraform:**
   ```bash
   git checkout -b fix/scp-emergency-rollback
   # Fix the SCP
   terraform apply
   git commit -m "fix(scp): correct overly restrictive deny rule"
   ```

### Module Hotfix Process

```bash
git checkout v1.2.0
git checkout -b hotfix/v1.2.1
# Apply minimal fix, test
git tag -a v1.2.1 -m "Hotfix: <description>"
git push origin v1.2.1
# Notify affected teams
```

---

## Appendix: Quick Reference

### Make Targets

```bash
make fmt          # Format all Terraform
make validate     # Validate all modules
make test-unit    # fmt + validate
make test-policy  # Conftest + Checkov
make test-e2e     # Terratest (requires AWS)
make test-all     # All tests
make docs         # Regenerate module READMEs
```

### Useful Commands

```bash
# Check for hardcoded account IDs
grep -rE "[0-9]{12}" modules/

# Validate all SCP JSON
for f in policies/scps/*.json; do jq . "$f" > /dev/null && echo "OK: $f"; done

# Find module usages in root configs
grep -r "source.*=" environments/*/main.tf
```
```
