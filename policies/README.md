# Policies Directory

This directory contains Policy-as-Code rules that are evaluated in CI against every Terraform plan.

## Structure

```
policies/
├── conftest/           # OPA/Conftest policies (Rego)
│   ├── terraform/      # Terraform-specific policies
│   └── conftest.toml   # Conftest configuration
├── checkov/            # Checkov custom policies
│   └── custom_checks/  # Custom Python checks
├── scps/               # Service Control Policy JSON documents
└── README.md
```

## Running Policies Locally

### Conftest (OPA)

```bash
# Install conftest
brew install conftest  # macOS
# or download from https://github.com/open-policy-agent/conftest/releases

# Run against a Terraform plan
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
conftest test tfplan.json -p policies/conftest/terraform
```

### Checkov

```bash
# Install checkov
pip install checkov

# Run against Terraform files
checkov -d environments/workload-template \
  --external-checks-dir policies/checkov/custom_checks \
  --framework terraform

# Run against a plan file
checkov -f tfplan.json --framework terraform_plan
```

## Policy Categories

| Category | Tool | Description |
|----------|------|-------------|
| Security | Conftest/Checkov | Encryption, access controls, network exposure |
| Cost | Conftest | Instance type allowlists, storage class restrictions |
| Tagging | Conftest | Required tag enforcement |
| Compliance | Checkov | CIS Benchmarks, AWS Best Practices |

## CI Integration

Policies are automatically evaluated in the GitHub Actions workflows:
- `terraform-plan.yml` runs both Conftest and Checkov
- High-severity findings fail the pipeline
- Suppressions require documented justification
