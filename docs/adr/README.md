# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) documenting significant decisions made in this landing zone blueprint.

## What is an ADR?

An ADR captures a single decision along with its context and consequences. They help future team members understand why we made certain choices.

## Format

Each ADR follows this template:

```markdown
# ADR-NNNN: Title

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Context
What is the issue that we are seeing that is motivating this decision?

## Decision
What is the change that we are proposing and/or doing?

## Consequences
What becomes easier or more difficult to do because of this change?
```

## Index

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-0001](0001-ou-structure.md) | Organizational Unit Structure | Accepted |
| [ADR-0002](0002-state-management.md) | Terraform State Management | Accepted |
| [ADR-0003](0003-tagging-standard.md) | Tagging Standard | Accepted |

## Creating a New ADR

1. Copy the template: `cp template.md NNNN-short-title.md`
2. Fill in the sections
3. Add to the index above
4. Submit via PR for review
