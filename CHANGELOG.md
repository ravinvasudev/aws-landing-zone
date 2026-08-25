# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Decoupled consumption model (ADR-0004)
- `state-bootstrap` module for product team state infrastructure
- Reusable GitHub Actions workflows (`reusable-terraform-plan.yml`, `reusable-terraform-apply.yml`)
- Product team template (`product-team-template/`)
- Module consumption guide (`docs/consumption-guide.md`)
- Module release workflow (`release-modules.yml`)

### Changed
- Updated README with operating model and module consumption patterns
- Reorganized repository structure to support decoupled consumption

## [0.1.0] - Initial Release

### Added
- Initial module implementations:
  - `account-baseline` - Per-account security baseline
  - `landing-zone-org` - AWS Organizations structure
  - `tagging` - Standard tag schema
  - `finops-budgets` - Budget and cost alerting
  - `network-vpc` - VPC with subnets
  - `iam-guardrails` - Permission boundaries
- Policy-as-Code:
  - Conftest/OPA policies for security, tagging, cost
  - Checkov custom checks
  - Service Control Policies (SCPs)
- Environment templates:
  - Management account configuration
  - Workload account template
- GitHub Actions workflows for plan/apply
- Architecture Decision Records (ADRs)
