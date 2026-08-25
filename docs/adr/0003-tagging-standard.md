# ADR-0003: Tagging Standard

## Status

Accepted

## Context

Consistent tagging is essential for:

- Cost allocation and showback/chargeback
- Resource ownership identification
- Compliance and data classification
- Automation and policy enforcement

We need to define mandatory tags, allowed values, and enforcement mechanisms.

## Decision

### Required Tags

All taggable resources MUST have these tags:

| Tag | Description | Example Values |
|-----|-------------|----------------|
| CostCenter | Billing allocation code | `platform`, `product-a`, `shared-services` |
| Owner | Team or individual responsible | `cloud-platform-team`, `team-a@example.com` |
| Environment | Deployment environment | `dev`, `staging`, `prod`, `sandbox`, `shared` |
| DataClassification | Data sensitivity level | `public`, `internal`, `confidential`, `restricted` |
| Product | Product or application name | `landing-zone`, `customer-api`, `payment-service` |

### Automatic Tags

Applied by the tagging module:

| Tag | Value |
|-----|-------|
| ManagedBy | `terraform` |
| Blueprint | `aws-landing-zone` |

### Enforcement

1. **Terraform validation**: Tagging module validates input values
2. **OPA/Conftest policies**: Block plans missing required tags
3. **AWS Tag Policies**: Enforce tag values at the Organizations level
4. **Config Rules**: Detect non-compliant resources post-deployment

### Implementation

All resources receive tags through the `tagging` module:

```hcl
module "tags" {
  source = "../../modules/tagging"
  
  cost_center         = "platform"
  owner               = "cloud-platform-team"
  environment         = "prod"
  data_classification = "internal"
  product             = "landing-zone"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
  tags   = module.tags.tags  # Never inline tags
}
```

## Consequences

### Positive

- Consistent cost allocation across all resources
- Easy identification of resource ownership
- Automated compliance checking
- Enables tag-based IAM policies

### Negative

- Additional overhead when creating resources
- Tag values must be coordinated across teams
- Retroactive tagging of existing resources required

### Risks

- Teams may use inconsistent tag values (mitigated by validation)
- Some resources do not support all tags
