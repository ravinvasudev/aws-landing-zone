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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional optional tags to include | `map(string)` | `{}` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center code for billing allocation | `string` | n/a | yes |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | Data classification level for compliance | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment designation | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Team or individual responsible for the resource (email or team name) | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Product or application name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_allocation_tags"></a> [cost\_allocation\_tags](#output\_cost\_allocation\_tags) | Tags used for cost allocation reports |
| <a name="output_required_tags"></a> [required\_tags](#output\_required\_tags) | Only the required tags (for validation purposes) |
| <a name="output_tag_policy_document"></a> [tag\_policy\_document](#output\_tag\_policy\_document) | AWS Organizations tag policy document enforcing the tag schema |
| <a name="output_tags"></a> [tags](#output\_tags) | Complete tag map to apply to resources |
<!-- END_TF_DOCS -->