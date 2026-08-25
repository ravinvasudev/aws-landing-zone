# Network VPC Module

Creates a standardized VPC structure with public, private, and isolated subnets, NAT Gateways, VPC Endpoints, and Flow Logs.

## Features

- Multi-AZ subnet layout (public, private, isolated tiers)
- NAT Gateways for private subnet egress (single or per-AZ)
- VPC Endpoints for S3 and DynamoDB (Gateway endpoints)
- Interface endpoints for other AWS services
- VPC Flow Logs to CloudWatch Logs
- DNS hostnames and support enabled

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/your-org/aws-landing-zone.git//modules/network-vpc?ref=v1.0.0"

  vpc_name = "workload-prod"
  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  isolated_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false  # One NAT per AZ for high availability

  enable_vpc_endpoints  = true
  vpc_endpoint_services = ["s3", "dynamodb"]

  enable_flow_logs        = true
  flow_log_retention_days = 30

  tags = module.tags.tags
}
```

## Subnet Tiers

| Tier | Internet Access | Use Case |
|------|-----------------|----------|
| Public | Direct (IGW) | Load balancers, bastion hosts |
| Private | Outbound only (NAT) | Application servers, containers |
| Isolated | None | Databases, sensitive workloads |

## Cost Optimization

- Set `single_nat_gateway = true` in non-production to reduce NAT costs
- VPC Endpoints for S3/DynamoDB avoid NAT Gateway data processing charges
- Flow Logs retention can be reduced in dev environments

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0, < 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_name | Name for the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | n/a | yes |
| availability_zones | List of AZs to use | `list(string)` | n/a | yes |
| public_subnet_cidrs | CIDRs for public subnets | `list(string)` | `[]` | no |
| private_subnet_cidrs | CIDRs for private subnets | `list(string)` | `[]` | no |
| isolated_subnet_cidrs | CIDRs for isolated subnets | `list(string)` | `[]` | no |
| enable_nat_gateway | Create NAT Gateways | `bool` | `true` | no |
| single_nat_gateway | Use single NAT Gateway | `bool` | `false` | no |
| enable_vpc_endpoints | Create VPC Endpoints | `bool` | `true` | no |
| vpc_endpoint_services | Services for VPC endpoints | `list(string)` | `["s3", "dynamodb"]` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `true` | no |
| flow_log_retention_days | Flow log retention | `number` | `30` | no |
| enable_dns_hostnames | Enable DNS hostnames | `bool` | `true` | no |
| enable_dns_support | Enable DNS support | `bool` | `true` | no |
| tags | Tags for VPC resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| isolated_subnet_ids | List of isolated subnet IDs |
| nat_gateway_ids | List of NAT Gateway IDs |
| internet_gateway_id | The Internet Gateway ID |
| vpc_endpoint_s3_id | S3 VPC Endpoint ID |
| vpc_endpoint_dynamodb_id | DynamoDB VPC Endpoint ID |
| flow_log_id | VPC Flow Log ID |
| availability_zones | AZs used |

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
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use | `list(string)` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | Whether to enable VPC Flow Logs | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Whether to create NAT Gateways for private subnets | `bool` | `true` | no |
| <a name="input_enable_vpc_endpoints"></a> [enable\_vpc\_endpoints](#input\_enable\_vpc\_endpoints) | Whether to create VPC Endpoints for AWS services | `bool` | `true` | no |
| <a name="input_flow_log_retention_days"></a> [flow\_log\_retention\_days](#input\_flow\_log\_retention\_days) | Number of days to retain flow logs | `number` | `30` | no |
| <a name="input_isolated_subnet_cidrs"></a> [isolated\_subnet\_cidrs](#input\_isolated\_subnet\_cidrs) | CIDR blocks for isolated subnets with no internet access (one per AZ) | `list(string)` | `[]` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets (one per AZ) | `list(string)` | `[]` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets (one per AZ) | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Use a single NAT Gateway for all AZs (cost savings, reduced availability) | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all VPC resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_vpc_endpoint_services"></a> [vpc\_endpoint\_services](#input\_vpc\_endpoint\_services) | List of AWS services to create VPC endpoints for | `list(string)` | <pre>[<br/>  "s3",<br/>  "dynamodb"<br/>]</pre> | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of availability zones used |
| <a name="output_flow_log_id"></a> [flow\_log\_id](#output\_flow\_log\_id) | The ID of the VPC Flow Log |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The ID of the Internet Gateway |
| <a name="output_isolated_subnet_ids"></a> [isolated\_subnet\_ids](#output\_isolated\_subnet\_ids) | List of isolated subnet IDs |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | List of NAT Gateway IDs |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | List of public subnet IDs |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_endpoint_dynamodb_id"></a> [vpc\_endpoint\_dynamodb\_id](#output\_vpc\_endpoint\_dynamodb\_id) | The ID of the DynamoDB VPC Endpoint |
| <a name="output_vpc_endpoint_s3_id"></a> [vpc\_endpoint\_s3\_id](#output\_vpc\_endpoint\_s3\_id) | The ID of the S3 VPC Endpoint |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->