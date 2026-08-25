# Tagging Module

Defines and enforces the organization's tagging standard. All resources should receive tags through this module's outputs to ensure consistency across the landing zone.

## Required Tags

| Tag | Description | Example |
|-----|-------------|---------|
| CostCenter | Cost center code for billing allocation | `platform`, `product-a` |
| Owner | Team or individual responsible | `cloud-platform-team` |
| Environment | Environment designation | `dev`, `staging`, `prod`, `sandbox`, `shared` |
| DataClassification | Data sensitivity level | `public`, `internal`, `confidential`, `restricted` |
| Product | Product or application name | `landing-zone`, `customer-api` |

## Automatic Tags

The module automatically adds:
- `ManagedBy = "terraform"`
- `Blueprint = "aws-landing-zone"`

## Usage

```hcl
module "tags" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/tagging?ref=v1.0.0"

  cost_center         = "platform"
  owner               = "cloud-platform-team"
  environment         = "prod"
  data_classification = "internal"
  product             = "landing-zone"

  additional_tags = {
    Backup = "daily"
  }
}

# Use in resources
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
  tags   = module.tags.tags
}
```

## Tag Policy Enforcement

The module outputs a `tag_policy_document` that can be attached to OUs via AWS Organizations to enforce tagging compliance.

```hcl
resource "aws_organizations_policy" "tagging" {
  name        = "RequiredTags"
  description = "Enforce required tagging schema"
  type        = "TAG_POLICY"
  content     = module.tags.tag_policy_document
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cost_center | Cost center code | `string` | n/a | yes |
| owner | Resource owner | `string` | n/a | yes |
| environment | Environment designation | `string` | n/a | yes |
| data_classification | Data classification level | `string` | n/a | yes |
| product | Product name | `string` | n/a | yes |
| additional_tags | Additional optional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| tags | Complete tag map for resources |
| required_tags | Only required tags |
| cost_allocation_tags | Tags for cost allocation |
| tag_policy_document | AWS Organizations tag policy JSON |
