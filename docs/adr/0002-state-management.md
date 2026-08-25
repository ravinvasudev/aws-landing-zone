# ADR-0002: Terraform State Management

## Status

Accepted

## Context

Terraform state must be stored securely and accessed by multiple team members and CI/CD pipelines. We need to decide:

- Where to store state
- How to handle locking
- State file granularity (one per account, per environment, per module)

## Decision

We will use S3 + DynamoDB for remote state with the following conventions:

### Backend Configuration

```hcl
backend "s3" {
  bucket         = "${org_name}-terraform-state"
  key            = "${account_or_env}/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

### State File Granularity

- One state file per environment/account deployment
- Modules do not have their own state (they are consumed by root configs)
- State bucket lives in a dedicated "infrastructure" or "management" account

### Key Structure

```
terraform-state/
├── management/terraform.tfstate
├── security/terraform.tfstate
├── workloads/customer-api-prod/terraform.tfstate
├── workloads/customer-api-dev/terraform.tfstate
└── ...
```

### Access Control

- CI/CD pipeline role has read/write access
- Developers have read-only access (no manual applies)
- State bucket has versioning enabled for recovery

## Consequences

### Positive

- Centralized state with audit trail
- Locking prevents concurrent modifications
- Encryption at rest and in transit
- Versioning enables state recovery

### Negative

- Single point of failure (mitigated by S3 durability)
- Cross-account access configuration required
- State bucket must be bootstrapped manually

### Risks

- State corruption requires versioning rollback
- Accidental state deletion (mitigated by MFA delete, versioning)
