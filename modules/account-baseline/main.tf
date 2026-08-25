# ------------------------------------------------------------------------------
# Account Baseline Module
# Per-account bootstrap: CloudTrail, Config, GuardDuty, IAM boundary
# ------------------------------------------------------------------------------

# This module establishes the security and compliance baseline for every AWS account
# in the organization. It should be applied to all accounts via the account vending
# process.

# TODO: Implement the following resources:
# - AWS CloudTrail (account-level trail, if not using org trail)
# - AWS Config recorder and delivery channel
# - GuardDuty detector enrollment
# - IAM permission boundary attachment
# - Default EBS encryption
# - S3 account-level public access block
