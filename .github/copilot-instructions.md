# AWS CCoE Landing Zone Blueprint

## Who I Am (context for every suggestion)

I'm Ravin Vasudev, a Cloud and Platform Architect with 19+ years across enterprise
software engineering, distributed systems, and Cloud Center of Excellence (CCoE).I currently work inside
a CCoE defining enterprise cloud standards, multi-account landing zone blueprints,
IaC conventions, and FinOps guardrails that multiple autonomous product teams build
on top of. Treat me as the architecture owner, but do not skip introductory
explanations of Terraform/AWS basics as ther consumers of this repo may be new to IaC or AWS.

**Working principles to apply when generating or reviewing anything in this repo:**
- Guardrails beat gatekeeping — prefer automated policy (SCPs, OPA/Conftest, Checkov)
  over manual review steps or approval queues.
- Every standard ships with a reference implementation — modules must be usable
  out of the box via `terraform init && terraform plan`, not just documented.
- Paved roads, not paved walls — defaults should be safe and cost-aware, but
  product teams must be able to extend via variables, not forks.
- Measure the outcome — cost, deployment velocity, and drift/compliance are the
  scorecard, not architecture diagrams.

---

## Project Purpose

This repository is a **CCoE Landing Zone Blueprint**: a reusable, opinionated set of
Terraform/OpenTofu modules and reference root configurations that let autonomous
product teams stand up a compliant AWS multi-account environment without needing
central platform team involvement for every account.

### Bare essentials this repo must cover

| Pillar | What "done" looks like |
| :--- | :--- |
| **AWS Landing Zones** | Multi-account structure (Organizations, OUs per environment/workload), account vending pattern, baseline account bootstrap module |
| **Policy as Code** | Service Control Policies (SCPs) as Terraform, OPA/Conftest or Checkov policies run in CI against every plan |
| **FinOps** | Budgets + alerts module, cost allocation tags enforced, Cost Anomaly Detection, showback/chargeback tag schema |
| **Guardrails** | IAM permission boundaries, mandatory encryption (KMS), no public S3/EBS by default, region restrictions |
| **Tagging** | Central tagging module/standard (`CostCenter`, `Owner`, `Environment`, `DataClassification`, `Product`) enforced via policy, not convention |
| **Risk Controls** | SCP deny-lists, GuardDuty/Security Hub baseline, CloudTrail org trail, config rules for drift detection |
| **Reusable Modules** | Versioned, composable Terraform modules (network, IAM, EKS/compute, logging) published for consumption by product teams |
| **Cost** | Budget alarms, rightsizing guardrails (instance/storage type allowlists), cost dashboards as code |
| **GitOps** | All changes flow through PR + plan/apply pipeline (GitHub Actions or Atlantis); no manual console changes to guarded resources |

---

## Tech Stack Defaults

Use these unless the repo's actual `versions.tf` / `README.md` says otherwise —
always check those files first before assuming versions.

| Layer | Technology |
| :--- | :--- |
| IaC | Terraform (or OpenTofu) — check `required_version` in root modules |
| Cloud | AWS (Organizations, or custom account factory) |
| Policy as Code | Open Policy Agent (Conftest) and/or Checkov, run in CI pre-apply |
| GitOps / CI-CD | GitHub Actions  driving `plan` on PR, `apply` on merge to main |
| State | Remote state in S3 + DynamoDB lock table (or Terraform Cloud), one state per account/workload |
| Secrets | AWS Secrets Manager / SSM Parameter Store — never hardcoded, never in `.tfvars` committed to git |
| Module Registry | Private Terraform module registry or Git tags (`vX.Y.Z`) for module consumption |
| Observability | CloudTrail org trail, Config, Security Hub, GuardDuty baseline modules |

---

## Repository Conventions

### Structure

```text
modules/                     # Reusable, versioned modules — no environment-specific values
  account-baseline/          # Per-account bootstrap: CloudTrail, Config, GuardDuty, IAM boundary
  landing-zone-org/          # AWS Organizations, OUs, SCPs
  tagging/                   # Standard tag schema + enforcement policy
  finops-budgets/            # Budgets, cost anomaly detection, alerting
  network-vpc/               # VPC, subnets, endpoints
  iam-guardrails/            # Permission boundaries, roles, SCP attachments
  eks-baseline/ (if used)    # Cluster baseline with guardrails pre-wired
environments/ or accounts/   # Root configs per account/environment — thin, calls modules only
policies/                    # OPA/Conftest or Checkov policy-as-code rules
.github/workflows/           # Plan-on-PR, apply-on-merge pipelines
docs/                        # Architecture decision records (ADRs), module usage guides
```

### Module Rules

- Every module has: `README.md` (generated via `terraform-docs`), `variables.tf` with
  descriptions and validation blocks, `outputs.tf`, and pinned provider versions.
- No module should hardcode account IDs, regions, or environment names — pass via
  variables with sane, safe defaults.
- Root/environment configs are thin: they compose modules and supply account-specific
  variables. Logic belongs in modules, not root configs.
- Tag every taggable resource through the shared `tagging` module output — never
  inline ad hoc tag maps in a root config.
- Version modules with semantic version tags; consuming root configs pin an explicit
  version (`?ref=vX.Y.Z`), never `main`/`HEAD`.

### Policy as Code / Guardrails

- Every SCP, IAM boundary, and Config rule is defined in Terraform, reviewed via PR,
  and tested against a policy test suite before merge.
- Run Checkov and/or Conftest in CI on every `terraform plan`; fail the pipeline on
  high-severity findings unless explicitly suppressed with a documented reason.
- Never generate a module or resource that disables encryption, opens `0.0.0.0/0`
  ingress, or grants `*:*` IAM actions without an explicit, called-out justification.

### FinOps / Cost

- Every account-vending or resource-provisioning module must wire in the shared
  budget/alerting module by default; do not make FinOps opt-in.
- Prefer variables that constrain instance/storage classes to an approved allowlist
  over unrestricted free-form input.

### GitOps Workflow

- All infrastructure changes are proposed via PR. CI runs `fmt`, `validate`, `plan`,
  policy scans, and posts the plan as a PR comment. Apply happens only after merge
  to `main`, via pipeline — never manual `terraform apply` from a laptop against
  shared/production accounts.
- State must never be manipulated manually (`terraform state rm`/`mv`) outside of a
  documented, reviewed break-glass procedure.

---

## Development Rules

| Category | Guidelines |
| :--- | :--- |
| **Terraform Style** | `terraform fmt` clean, resources named by purpose not type, use `for_each` over `count` for anything keyed by identity |
| **Variables** | Explicit `type`, `description`, and `validation` blocks on every variable in a module |
| **Outputs** | Every module exposes the identifiers/ARNs downstream modules or teams need — no undocumented "figure it out from the console" |
| **Testing** | Prefer Terratest or `terraform test` for module validation; policy tests via Conftest for SCP/guardrail logic |
| **Documentation** | `terraform-docs` generated README per module; ADRs in `docs/adr/` for any structural decision (OU design, account vending pattern, etc.) |
| **Security** | Least privilege IAM by default, no long-lived credentials, no secrets in state or vars committed to git |
| **Validation** | `terraform fmt -check`, `terraform validate`, `checkov`/`conftest`, and `terraform plan` must all pass before suggesting a change is complete |

---

## Formatting Rule

Do not use em dashes in generated documentation or commit messages. Use colons,
hyphens, or parenthetical phrases.
