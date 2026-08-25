# Product Team Infrastructure Template

Starter template for product teams to set up their own Terraform repository. For complete documentation, see the [Consumption Guide](../docs/consumption-guide.md).

## What's Included

```
├── .github/workflows/       # CI/CD calling CCoE reusable workflows
├── state-bootstrap/         # One-time state backend setup (S3 + DynamoDB)
└── environments/            # Per-environment Terraform configs
    ├── dev/
    └── prod/
```

## Quick Start

1. Copy this template to your repository
2. Bootstrap state: `cd state-bootstrap && terraform init && terraform apply`
3. Configure environment: `cd environments/dev && terraform init`
4. Set GitHub secrets: `AWS_PLAN_ROLE_ARN`, `AWS_APPLY_ROLE_ARN`, `TF_REGISTRY_TOKEN`
5. Push and create a PR to trigger the pipeline

See [Consumption Guide: Getting Started](../docs/consumption-guide.md#getting-started) for detailed steps.
