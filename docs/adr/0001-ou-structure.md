# ADR-0001: Organizational Unit Structure

## Status

Accepted

## Context

We need to define the AWS Organizations OU structure that balances security isolation, operational efficiency, and team autonomy. The structure must support:

- Centralized security and audit capabilities
- Environment-based policy application (prod vs non-prod)
- Team autonomy for workload accounts
- Clear cost allocation
- Account lifecycle management

## Decision

We will implement the following OU hierarchy:

```
Root
├── Security          # Log Archive, Audit, Security Hub delegated admin
├── Infrastructure    # Shared services (networking, identity, CI/CD)
├── Workloads
│   ├── Production    # Prod workload accounts (stricter SCPs)
│   └── NonProduction # Dev/staging accounts (relaxed SCPs)
├── Sandbox           # Developer experimentation (time-boxed, budget-limited)
└── Suspended         # Accounts pending deletion
```

### Rationale

1. **Security OU**: Isolates security tooling from workloads. These accounts have different access patterns and should not be subject to workload SCPs.

2. **Infrastructure OU**: Shared services that multiple workloads depend on. Centralized networking enables Transit Gateway and VPC peering patterns.

3. **Workloads split by environment**: Allows applying stricter SCPs to production (e.g., deny delete operations) while giving non-production more flexibility.

4. **Sandbox OU**: Enables experimentation without risking production. Budget limits and auto-cleanup prevent cost overruns.

5. **Suspended OU**: Provides a holding area for accounts being decommissioned. SCPs deny all actions except those needed for deletion.

## Consequences

### Positive

- Clear separation of concerns
- SCPs can target specific environments
- Easy to identify account purpose from OU placement
- Supports compliance requirements (prod isolation)

### Negative

- Accounts cannot span multiple OUs (e.g., a shared dev/staging account)
- Moving accounts between OUs requires coordination
- More OUs means more SCP management

### Risks

- Teams may request exceptions to OU placement
- OU structure changes are disruptive once accounts are deployed
