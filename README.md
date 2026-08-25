# AWS CCoE Landing Zone Blueprint

A reusable, opinionated set of Terraform modules and reference configurations for deploying a compliant AWS multi-account environment.

## Overview

This repository provides a Cloud Center of Excellence (CCoE) Landing Zone Blueprint that enables autonomous product teams to stand up compliant AWS environments without central platform team involvement for every account.

## Operating Model

This blueprint follows a **decoupled consumption model**:

| Component | Owner | Location |
|-----------|-------|----------|
| Terraform Modules | CCoE | This repository, published via Terraform Registry or Git tags |
| Reusable Workflows | CCoE | `.github/workflows/reusable-*.yml` in this repository |
| Policy Rules | CCoE | `policies/` in this repository |
| Environment Configs | Product Teams | Team's own repository |
| State Files | Product Teams | Team's own S3 bucket |
| Pipeline Execution | Product Teams | Team's GitHub Actions calling CCoE workflows |

**For product teams**: See the [Consumption Guide](docs/consumption-guide.md) and [product-team-template/](product-team-template/) for getting started.

## Repository Structure

```
aws-landing-zone/
├── modules/                         # Reusable Terraform modules (published to registry)
│   ├── account-baseline/            # Per-account security baseline
│   ├── landing-zone-org/            # AWS Organizations, OUs, SCPs
│   ├── tagging/                     # Standard tag schema and enforcement
│   ├── finops-budgets/              # Budgets, cost anomaly detection
│   ├── network-vpc/                 # VPC, subnets, endpoints
│   ├── iam-guardrails/              # Permission boundaries, roles
│   └── state-bootstrap/             # State backend (S3 + DynamoDB) for product teams
├── environments/                    # CCoE-managed environment configs
│   ├── management/                  # AWS Organizations management account
│   └── workload-template/           # Template for workload accounts
├── product-team-template/           # Starter template for product team repositories
│   ├── .github/workflows/           # Workflow calling CCoE reusable workflows
│   ├── environments/                # Example dev/prod environment structure
│   └── state-bootstrap/             # State backend bootstrap for teams
├── policies/                        # Policy-as-Code rules
│   ├── conftest/                    # OPA/Rego policies
│   ├── checkov/                     # Checkov custom checks
│   └── scps/                        # Service Control Policy JSON
├── docs/                            # Documentation
│   ├── adr/                         # Architecture Decision Records
│   └── consumption-guide.md         # Guide for product teams
└── .github/workflows/               # CI/CD pipelines
    ├── terraform-plan.yml           # Plan workflow for this repo
    ├── terraform-apply.yml          # Apply workflow for this repo
    ├── reusable-terraform-plan.yml  # Reusable plan (for product teams)
    └── reusable-terraform-apply.yml # Reusable apply (for product teams)
```

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with appropriate credentials
- Access to an AWS Organizations management account

### Deploy the Landing Zone

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/aws-landing-zone.git
   cd aws-landing-zone
   ```

2. **Configure the management account**
   ```bash
   cd environments/management
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize and apply**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Create a Workload Account

1. **Copy the template**
   ```bash
   cp -r environments/workload-template environments/my-workload-prod
   ```

2. **Configure the workload**
   ```bash
   cd environments/my-workload-prod
   # Edit main.tf to configure backend
   # Create terraform.tfvars with workload-specific values
   ```

3. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Modules

| Module | Description |
|--------|-------------|
| [account-baseline](modules/account-baseline/) | Security baseline (GuardDuty, Config, CloudTrail) |
| [landing-zone-org](modules/landing-zone-org/) | AWS Organizations structure and SCPs |
| [tagging](modules/tagging/) | Standard tag schema and enforcement |
| [finops-budgets](modules/finops-budgets/) | Cost management and alerting |
| [network-vpc](modules/network-vpc/) | VPC with public/private/isolated subnets |
| [iam-guardrails](modules/iam-guardrails/) | Permission boundaries and baseline roles |
| [state-bootstrap](modules/state-bootstrap/) | Terraform state backend for product teams |

## Policy Enforcement

All changes are validated against policy-as-code rules (Conftest, Checkov) and organization-wide SCPs. See [policies/README.md](policies/README.md).

## Documentation

| Document | Audience | Description |
|----------|----------|-------------|
| [Consumption Guide](docs/consumption-guide.md) | Product Teams | Request accounts, consume modules, troubleshooting |
| [CCoE Development Guide](docs/ccoe-development-guide.md) | CCoE Team | Module development, policy authoring, releases |
| [Architecture Decision Records](docs/adr/) | All | Key design decisions |
| [Policies README](policies/README.md) | All | Policy-as-code rules |

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `terraform fmt` and `terraform validate`
4. Submit a pull request
5. Address review feedback
6. Merge after approval

## License

Copyright (c) 2024. All rights reserved.
