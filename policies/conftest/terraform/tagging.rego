# Terraform Tagging Policies
# OPA/Rego policies for tag enforcement

package terraform.tagging

import future.keywords.in
import future.keywords.if

# Required tags that must be present on all taggable resources
required_tags := ["CostCenter", "Owner", "Environment", "DataClassification", "Product"]

# Resource types that must have tags
taggable_resource_types := [
    "aws_instance",
    "aws_s3_bucket",
    "aws_rds_cluster",
    "aws_db_instance",
    "aws_lambda_function",
    "aws_ecs_cluster",
    "aws_ecs_service",
    "aws_eks_cluster",
    "aws_vpc",
    "aws_subnet",
    "aws_security_group",
    "aws_lb",
    "aws_lb_target_group",
    "aws_ebs_volume",
    "aws_kms_key",
    "aws_sns_topic",
    "aws_sqs_queue",
    "aws_dynamodb_table"
]

# ------------------------------------------------------------------------------
# Deny resources missing required tags
# ------------------------------------------------------------------------------

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type in taggable_resource_types
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    tags := object.get(change, "tags", {})
    
    required_tag := required_tags[_]
    not tags[required_tag]
    
    msg := sprintf(
        "Resource '%s' is missing required tag '%s'",
        [resource.address, required_tag]
    )
}

# ------------------------------------------------------------------------------
# Warn on empty tag values
# ------------------------------------------------------------------------------

warn[msg] if {
    resource := input.resource_changes[_]
    resource.type in taggable_resource_types
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    tags := object.get(change, "tags", {})
    
    some tag_key
    tags[tag_key] == ""
    
    msg := sprintf(
        "Resource '%s' has empty value for tag '%s'",
        [resource.address, tag_key]
    )
}

# ------------------------------------------------------------------------------
# Validate Environment tag values
# ------------------------------------------------------------------------------

valid_environments := ["dev", "staging", "prod", "sandbox", "shared"]

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type in taggable_resource_types
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    tags := object.get(change, "tags", {})
    
    env := tags.Environment
    not env in valid_environments
    
    msg := sprintf(
        "Resource '%s' has invalid Environment tag '%s' (must be one of: %v)",
        [resource.address, env, valid_environments]
    )
}

# ------------------------------------------------------------------------------
# Validate DataClassification tag values
# ------------------------------------------------------------------------------

valid_classifications := ["public", "internal", "confidential", "restricted"]

deny[msg] if {
    resource := input.resource_changes[_]
    resource.type in taggable_resource_types
    resource.change.actions[_] in ["create", "update"]
    
    change := resource.change.after
    tags := object.get(change, "tags", {})
    
    classification := tags.DataClassification
    not classification in valid_classifications
    
    msg := sprintf(
        "Resource '%s' has invalid DataClassification tag '%s' (must be one of: %v)",
        [resource.address, classification, valid_classifications]
    )
}
