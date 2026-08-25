# ------------------------------------------------------------------------------
# Network VPC Module - Outputs
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = null # TODO: Replace with aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = null # TODO: Replace with aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [] # TODO: Replace with aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [] # TODO: Replace with aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "List of isolated subnet IDs"
  value       = [] # TODO: Replace with aws_subnet.isolated[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [] # TODO: Replace with aws_nat_gateway.this[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = null # TODO: Replace with aws_internet_gateway.this.id
}

output "vpc_endpoint_s3_id" {
  description = "The ID of the S3 VPC Endpoint"
  value       = null # TODO: Replace with aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of the DynamoDB VPC Endpoint"
  value       = null # TODO: Replace with aws_vpc_endpoint.dynamodb.id
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = null # TODO: Replace with aws_flow_log.this.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}
