# Governance Module

## Overview

The governance module implements organizational governance and compliance infrastructure for the Azure landing zone. It establishes management group hierarchy, Azure Policy enforcement, and cost management controls.

## Resources Created

- **Management Groups**: Hierarchical organizational structure (root, platform, workloads)
- **Azure Policy Definitions**: Custom policies for tagging and network restrictions
- **Azure Policy Assignments**: Built-in and custom policy enforcement
- **Budget Alerts**: Cost governance via subscription-level budget monitoring

## Governance Strategy

| Policy | Dev Effect | Staging Effect | Production Effect |
|--------|-----------|---------------|-------------------|
| Required Tags | Audit | Audit | Deny |
| Deny Public IPs | Audit | Audit | Deny |
| Security Benchmark | Audit | Audit | Audit |

- **Audit**: Logs non-compliance without blocking resource creation
- **Deny**: Prevents non-compliant resource creation entirely
- Production uses stricter enforcement to ensure compliance

## Usage

```hcl
module "governance" {
  source = "../../modules/governance"

  environment              = "dev"
  organization_name        = "contoso"
  enable_policy_assignments = true
  enable_budget_alerts     = true
  monthly_budget_amount    = 500
  budget_alert_emails      = ["ops@contoso.com"]

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "azure-landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name (dev, staging, production) | string | n/a | yes |
| organization_name | Organization name for management groups | string | "azure-landing-zone" | no |
| enable_policy_assignments | Enable Azure Policy assignments | bool | true | no |
| required_tags | Tag keys required on all resources | list(string) | ["environment", "managed_by", "project"] | no |
| enable_budget_alerts | Enable Azure budget alerts | bool | false | no |
| monthly_budget_amount | Monthly budget amount | number | 1000 | no |
| budget_start_date | Budget start date (YYYY-MM-DD) | string | "2025-01-01" | no |
| budget_alert_emails | Emails for budget alerts | list(string) | [] | no |
| tags | Tags for governance resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| root_management_group_id | Resource ID of the root management group |
| platform_management_group_id | Resource ID of the platform management group |
| workloads_management_group_id | Resource ID of the workloads management group |
| security_benchmark_assignment_id | Resource ID of the ASB policy assignment |
| require_tags_policy_id | Resource ID of the require-tags policy |
| deny_public_ip_policy_id | Resource ID of the deny-public-ip policy |
| monthly_budget_id | Resource ID of the monthly budget |

## Dependencies

This module has no dependencies on other modules. It operates at the subscription and management group level.

## Next Steps

- Define management group hierarchy
- Assign Azure Security Benchmark initiative
- Create custom tag enforcement policies
- Configure budget alerts with appropriate thresholds
- Add policy exemptions for known exceptions
- Implement policy remediation tasks for existing resources
