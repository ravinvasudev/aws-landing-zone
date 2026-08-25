# Terraform Security Policies
# OPA/Rego policies for Terraform plans

package terraform.security

import future.keywords.in
import future.keywords.if

# ------------------------------------------------------------------------------
# Deny public S3 buckets
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    change := resource.change.after
    
    # All of these should be true
    not change.block_public_acls
    
    msg := sprintf(
        "S3 bucket public access block '%s' must have block_public_acls enabled",
        [resource.address]
    )
}

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    change := resource.change.after
    
    not change.block_public_policy
    
    msg := sprintf(
        "S3 bucket public access block '%s' must have block_public_policy enabled",
        [resource.address]
    )
}

# ------------------------------------------------------------------------------
# Deny unencrypted EBS volumes
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    change := resource.change.after
    
    not change.encrypted
    
    msg := sprintf(
        "EBS volume '%s' must have encryption enabled",
        [resource.address]
    )
}

# ------------------------------------------------------------------------------
# Deny unencrypted RDS instances
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    change := resource.change.after
    
    not change.storage_encrypted
    
    msg := sprintf(
        "RDS instance '%s' must have storage_encrypted enabled",
        [resource.address]
    )
}

# ------------------------------------------------------------------------------
# Deny publicly accessible RDS instances
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    change := resource.change.after
    
    change.publicly_accessible
    
    msg := sprintf(
        "RDS instance '%s' must not be publicly accessible",
        [resource.address]
    )
}

# ------------------------------------------------------------------------------
# Deny security groups with 0.0.0.0/0 ingress
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group_rule"
    change := resource.change.after
    
    change.type == "ingress"
    change.cidr_blocks[_] == "0.0.0.0/0"
    
    # Allow only HTTPS (443) from anywhere
    change.from_port != 443
    
    msg := sprintf(
        "Security group rule '%s' allows ingress from 0.0.0.0/0 on port %d (only 443 allowed)",
        [resource.address, change.from_port]
    )
}

# ------------------------------------------------------------------------------
# Deny IAM policies with wildcard actions
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_policy"
    change := resource.change.after
    
    policy := json.unmarshal(change.policy)
    statement := policy.Statement[_]
    
    statement.Effect == "Allow"
    statement.Action[_] == "*"
    
    msg := sprintf(
        "IAM policy '%s' contains wildcard (*) actions which is not allowed",
        [resource.address]
    )
}
