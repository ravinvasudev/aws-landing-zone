# Product Team Consumption Guide

How product teams request accounts, consume CCoE modules, and operate infrastructure.

## Table of Contents

- [Getting Started](#getting-started)
- [Requesting a New Account](#requesting-a-new-account)
- [Module Consumption](#module-consumption)
- [Pipeline and State](#pipeline-and-state)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Getting Started

### Prerequisites

- AWS account vended by CCoE (see [Requesting a New Account](#requesting-a-new-account))
- GitHub repository for your infrastructure code
- Terraform >= 1.5.0
- AWS CLI configured

### Quick Start

```bash
# 1. Copy template
cp -r aws-landing-zone/product-team-template/* my-team-infra/
cd my-team-infra

# 2. Bootstrap state backend
cd state-bootstrap
cp terraform.tfvars.example terraform.tfvars  # Edit with your values
terraform init && terraform apply

# 3. Configure first environment
cd ../environments/dev
# Update backend in main.tf with state-bootstrap outputs
cp terraform.tfvars.example terraform.tfvars  # Edit with your config
terraform init && terraform plan

# 4. Set GitHub secrets and push
# AWS_PLAN_ROLE_ARN, AWS_APPLY_ROLE_ARN, TF_REGISTRY_TOKEN
```

---

## Requesting a New Account

### When Do You Need a New Account?

| Scenario | Recommendation |
|----------|----------------|
| New product or service | New account in Workloads OU |
| New environment (dev, staging) for existing product | New account in appropriate OU |
| Experimentation or PoC | Sandbox account (time-limited) |
| Shared service used by multiple products | Discuss with CCoE first |

### Account Request Process

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   1. Submit      │────▶│   2. CCoE        │────▶│   3. Account     │────▶│   4. You         │
│   GitHub Issue   │     │   Reviews        │     │   Provisioned    │     │   Configure      │
│   (Use Template) │     │   (1-2 days)     │     │   (Automated)    │     │   Your Infra     │
└──────────────────┘     └──────────────────┘     └──────────────────┘     └──────────────────┘
```

### Request Template

Open an issue in the CCoE landing-zone repository using this template:

```markdown
## New Account Request

**Team Name:** Acme Team
**Cost Center:** CC-12345
**Account Purpose:** Production environment for Acme widget service
**Target OU:** Workloads/Production

**Monthly Budget Estimate:** $5,000
**Primary Owner Email:** alice@example.com
**Secondary Owner Email:** bob@example.com

### Justification
This account will host the Acme widget service, which is a customer-facing 
application requiring production-grade isolation and stricter SCPs.

### Architecture Overview
- 3-tier web application (ALB, ECS, RDS)
- Estimated 10-50 EC2-equivalent compute units
- Single region (us-east-1)

### Checklist
- [x] Cost center approved by Finance
- [x] Architecture review completed
- [x] Team has completed AWS onboarding training
```

### What You Receive

After approval, CCoE provides:

| Item | Description |
|------|-------------|
| **Account ID** | 12-digit AWS account number |
| **IAM Role ARNs** | `terraform-plan` and `terraform-apply` roles for GitHub Actions |
| **State Bucket Name** | Pre-created S3 bucket for Terraform state |
| **DynamoDB Table** | Lock table for state locking |
| **OU Placement** | Confirmation of which OU the account is placed in |
| **Budget Alert** | Pre-configured budget with your specified threshold |

### OU Placement Guide

| OU | Use Case | SCP Restrictions |
|----|----------|------------------|
| **Workloads/Production** | Customer-facing, revenue-critical | Strictest: no delete, mandatory encryption, region-locked |
| **Workloads/NonProduction** | Dev, staging, testing | Relaxed: allows experimentation, still enforces tagging |
| **Sandbox** | PoCs, learning, experiments | Time-limited (90 days), budget-capped ($500/month default), auto-cleanup |

---

## Module Consumption

### Using Modules

```hcl
# Preferred: Terraform Registry
module "vpc" {
  source  = "app.terraform.io/your-org/network-vpc/aws"
  version = "~> 1.2.0"
  # ...
}

# Alternative: Git reference (always pin version)
module "vpc" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/network-vpc?ref=v1.2.0"
  # ...
}
```

### Version Pinning

| Pattern | Meaning | Use Case |
|---------|---------|----------|
| `~> 1.2.0` | >= 1.2.0, < 1.3.0 | **Default choice** |
| `= 1.2.3` | Exact version | Maximum stability |
| `~> 1.0` | >= 1.0, < 2.0 | Stable, mature modules |

Never use `?ref=main` or omit version constraints.

---

## Pipeline and State

### GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_PLAN_ROLE_ARN` | IAM role for `terraform plan` |
| `AWS_APPLY_ROLE_ARN` | IAM role for `terraform apply` |
| `TF_REGISTRY_TOKEN` | Private registry access (optional) |

### State Backend

Bootstrap creates an S3 bucket and DynamoDB table. Configure each environment:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-team-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-team-terraform-lock"
    encrypt        = true
  }
}
```

### Automated Version Updates

Use Dependabot or Renovate to stay current with module versions. See the template's `.github/dependabot.yml` for configuration.

---

## Troubleshooting

### Module Not Found

```
Error: Failed to download module
```

**Causes and Solutions:**

| Cause | Solution |
|-------|----------|
| Tag does not exist | `git ls-remote --tags https://github.com/your-org/aws-landing-zone.git` |
| Registry auth expired | `terraform login app.terraform.io` |
| Network/firewall | Check VPN, corporate proxy settings |
| Typo in source | Verify module path matches directory structure |

### State Lock Error

```
Error: Error acquiring the state lock
```

**Solutions:**
1. Wait for other operations to complete (another team member may be applying)
2. Check DynamoDB table for stale locks:
   ```bash
   aws dynamodb scan --table-name my-team-terraform-lock
   ```
3. Force unlock (use with caution, ensure no one else is running):
   ```bash
   terraform force-unlock <LOCK_ID>
   ```

### Policy Violation

```
FAIL - conftest: policy/security.rego
  - S3 bucket 'module.storage.aws_s3_bucket.data' must have encryption enabled
```

**Resolution steps:**
1. Read the error message carefully (it explains what is wrong)
2. Fix your configuration to comply with the policy
3. Run `terraform plan` locally to verify the fix
4. If you believe this is a legitimate exception:
   - Document why in a PR comment
   - Contact CCoE to discuss a policy exception
   - Never suppress without CCoE approval

### Authentication Errors

```
Error: error configuring S3 Backend: no valid credential sources
```

**Solutions:**
1. Verify AWS credentials are configured:
   ```bash
   aws sts get-caller-identity
   ```
2. Check your IAM role has necessary permissions
3. For GitHub Actions, verify `AWS_PLAN_ROLE_ARN` secret is correct

### Provider Version Conflicts

```
Error: Failed to query available provider packages
```

**Solutions:**
1. Delete `.terraform.lock.hcl` and re-run `terraform init`
2. Check `versions.tf` for conflicting constraints
3. Ensure you are using Terraform >= 1.5.0

### Drift Detected

If `terraform plan` shows unexpected changes:

1. **Do not apply blindly.** Investigate why drift occurred.
2. Check if someone made manual console changes (not allowed for guarded resources)
3. Review CloudTrail for recent changes to the resource
4. If drift is legitimate (e.g., AWS auto-scaling), consider using `lifecycle { ignore_changes }`

---

## FAQ

**Can I use resources not covered by CCoE modules?**
Yes, but you must still comply with tagging and security policies. Request a module from CCoE if the pattern is reusable.

**Can I fork CCoE modules?**
No. Forks miss security updates. Use module variables to customize, or request new features via GitHub issue.

**How long does account provisioning take?**
1-2 business days for review, then ~15 minutes automated provisioning.

**Why is my action being denied?**
Check CloudTrail for `Access Denied` events with `policyType: SERVICE_CONTROL_POLICY`. Contact CCoE with event details.

**Can I get an SCP exception?**
Rarely. Document your use case and submit to CCoE. Security team reviews. If approved, CCoE implements a scoped exception.

**Which regions can I deploy to?**
Default: `us-east-1`, `us-west-2`. Request additional regions with business justification.

**Can I run `terraform apply` from my laptop?**
Dev/sandbox: yes. Production: no, must use GitHub Actions pipeline.

**What if my state file is corrupted?**
State bucket has versioning. Contact CCoE to restore from a previous version.

**What happens if I exceed my budget?**
You get alerts at 50%, 80%, 100%. Budgets do not stop spending. Contact FinOps if trending toward overrun.

---

## Getting Help

| Issue | Contact |
|-------|---------|
| Module bugs/features | GitHub issue in landing-zone repo |
| Policy exceptions | Slack #ccoe-support |
| Account requests | GitHub issue (use template) |
| Budget/cost | FinOps team |
| Security incident | Security incident process |

**Escalation**: Check docs → Search GitHub issues → #ccoe-support → Page CCoE on-call (if urgent, no response in 2h)
