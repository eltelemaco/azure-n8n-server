# Landing Zone Module

## Overview

The landing zone core module establishes foundational Azure infrastructure that other modules depend on. It provides centralized logging, monitoring, and resource organization for the Azure landing zone.

## Resources Created

- **Resource Group**: Primary container for all landing zone resources
- **Log Analytics Workspace**: Centralized log collection and analysis
- **Azure Monitor Action Groups**: Alert notification configuration
- **Diagnostic Settings**: Activity log forwarding to Log Analytics

## Usage

```hcl
module "landing_zone" {
  source = "../../modules/landing-zone"

  environment         = "dev"
  location            = "eastus"
  landing_zone_name   = "landing-zone"
  log_retention_days  = 30

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
| location | Azure region for resource deployment | string | n/a | yes |
| landing_zone_name | Name suffix for landing zone resources | string | "landing-zone" | no |
| resource_group_name | Name of existing resource group (if any) | string | "" | no |
| log_retention_days | Days to retain logs in Log Analytics | number | 30 | no |
| tags | Map of tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Name of the landing zone resource group |
| resource_group_id | Resource ID of the landing zone resource group |
| log_analytics_workspace_id | Resource ID of the Log Analytics workspace |
| log_analytics_workspace_name | Name of the Log Analytics workspace |
| critical_action_group_id | Resource ID of the critical alerts action group |

## Dependencies

This module has no dependencies on other modules. It is the foundational module that other modules depend on.

## Next Steps

- Implement resource group creation
- Add Log Analytics workspace
- Configure diagnostic settings
- Set up alert action groups
