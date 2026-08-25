# AWS CCoE Landing Zone Blueprint

A reusable, opinionated set of Terraform modules and reference configurations for deploying a compliant AWS multi-account environment.

## Overview

This repository provides a Cloud Center of Excellence (CCoE) Landing Zone Blueprint that enables autonomous product teams to stand up compliant AWS environments without central platform team involvement for every account.

## Repository Structure

```
aws-landing-zone/
├── modules/                    # Reusable Terraform modules
│   ├── account-baseline/       # Per-account security baseline
│   ├── landing-zone-org/       # AWS Organizations, OUs, SCPs
│   ├── tagging/                # Standard tag schema and enforcement
│   ├── finops-budgets/         # Budgets, cost anomaly detection
│   ├── network-vpc/            # VPC, subnets, endpoints
│   └── iam-guardrails/         # Permission boundaries, roles
├── environments/               # Root configs per account/environment
│   ├── management/             # AWS Organizations management account
│   └── workload-template/      # Template for workload accounts
├── policies/                   # Policy-as-Code rules
│   ├── conftest/               # OPA/Rego policies
│   ├── checkov/                # Checkov custom checks
│   └── scps/                   # Service Control Policy JSON
├── docs/                       # Documentation
│   └── adr/                    # Architecture Decision Records
└── .github/workflows/          # CI/CD pipelines
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

## Policy Enforcement

All infrastructure changes are validated against policy-as-code rules:

- **Conftest (OPA)**: Security, tagging, and cost policies
- **Checkov**: CIS Benchmarks and AWS best practices
- **SCPs**: Organization-wide guardrails

See [policies/README.md](policies/README.md) for details.

## CI/CD Workflow

```
PR Created → Format Check → Validate → Plan → Policy Scan → Review
                                                              ↓
                                              Merge to Main → Apply
```

- **Plan on PR**: Every pull request runs `terraform plan` and policy scans
- **Apply on merge**: Approved changes are applied automatically after merge
- **No manual applies**: All production changes flow through the pipeline

## Documentation

- [Architecture Decision Records](docs/adr/) - Key design decisions
- Module READMEs - Usage examples and input/output documentation

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `terraform fmt` and `terraform validate`
4. Submit a pull request
5. Address review feedback
6. Merge after approval

## License

Copyright (c) 2024. All rights reserved.
