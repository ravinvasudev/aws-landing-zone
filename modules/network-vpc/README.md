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
