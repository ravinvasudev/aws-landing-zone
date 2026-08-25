# Terraform Cost Policies
# OPA/Rego policies for cost guardrails

package terraform.cost

import future.keywords.in
import future.keywords.if

# ------------------------------------------------------------------------------
# Allowed EC2 instance types (cost guardrail)
# ------------------------------------------------------------------------------

allowed_instance_types := [
    # General purpose (current gen)
    "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge",
    "t3a.micro", "t3a.small", "t3a.medium", "t3a.large", "t3a.xlarge",
    "m6i.large", "m6i.xlarge", "m6i.2xlarge",
    "m6a.large", "m6a.xlarge", "m6a.2xlarge",
    
    # Compute optimized
    "c6i.large", "c6i.xlarge", "c6i.2xlarge",
    
    # Memory optimized
    "r6i.large", "r6i.xlarge", "r6i.2xlarge"
]

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    not change.instance_type in allowed_instance_types
    
    msg := sprintf(
        "EC2 instance '%s' uses disallowed instance type '%s'. Allowed types: %v",
        [resource.address, change.instance_type, allowed_instance_types]
    )
}

# ------------------------------------------------------------------------------
# Allowed RDS instance classes
# ------------------------------------------------------------------------------

allowed_rds_classes := [
    "db.t3.micro", "db.t3.small", "db.t3.medium", "db.t3.large",
    "db.t4g.micro", "db.t4g.small", "db.t4g.medium", "db.t4g.large",
    "db.r6g.large", "db.r6g.xlarge",
    "db.m6g.large", "db.m6g.xlarge"
]

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    not change.instance_class in allowed_rds_classes
    
    msg := sprintf(
        "RDS instance '%s' uses disallowed instance class '%s'. Allowed classes: %v",
        [resource.address, change.instance_class, allowed_rds_classes]
    )
}

# ------------------------------------------------------------------------------
# Warn on expensive storage types
# ------------------------------------------------------------------------------

warn[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    change.type == "io2"
    
    msg := sprintf(
        "EBS volume '%s' uses expensive io2 storage type - consider gp3 for cost savings",
        [resource.address]
    )
}

# ------------------------------------------------------------------------------
# Warn on large provisioned IOPS
# ------------------------------------------------------------------------------

warn[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    change.iops > 10000
    
    msg := sprintf(
        "EBS volume '%s' has high provisioned IOPS (%d) - review for cost optimization",
        [resource.address, change.iops]
    )
}

# ------------------------------------------------------------------------------
# Deny NAT Gateways in dev/sandbox without explicit override
# ------------------------------------------------------------------------------

warn[msg] if {
    resource := input.resource_changes[_]
    resource.type == "aws_nat_gateway"
    resource.change.actions[_] == "create"
    
    change := resource.change.after
    tags := object.get(change, "tags", {})
    env := object.get(tags, "Environment", "unknown")
    
    env in ["dev", "sandbox"]
    not tags.CostOverride
    
    msg := sprintf(
        "NAT Gateway '%s' in %s environment - consider using NAT instances or VPC endpoints for cost savings. Add tag CostOverride=approved to suppress.",
        [resource.address, env]
    )
}
