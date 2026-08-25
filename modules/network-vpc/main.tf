# ------------------------------------------------------------------------------
# Network VPC Module
# VPC, subnets, endpoints
# ------------------------------------------------------------------------------

# This module creates a standardized VPC structure with:
# - Public, private, and isolated subnets across multiple AZs
# - NAT Gateways for private subnet egress
# - VPC Endpoints for AWS services (avoiding NAT costs)
# - Flow logs for network visibility

# TODO: Implement the following resources:
# - aws_vpc
# - aws_subnet (public, private, isolated per AZ)
# - aws_internet_gateway
# - aws_nat_gateway
# - aws_route_table and associations
# - aws_vpc_endpoint (S3, DynamoDB, and interface endpoints)
# - aws_flow_log
