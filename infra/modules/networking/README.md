# Networking Module

## Overview

The networking module implements a hub-and-spoke virtual network topology for the Azure landing zone. It provides network isolation, segmentation, and secure connectivity following Azure Well-Architected Framework best practices.

## Architecture

```
Hub VNet (10.0.0.0/16)          Spoke VNet (10.1.0.0/16)
+---------------------+        +---------------------+
| Management Subnet   |        | Web Subnet          |
| (10.0.1.0/24)       |        | (10.1.1.0/24)       |
+---------------------+  Peer  +---------------------+
| Bastion Subnet      | <----> | App Subnet          |
| (10.0.2.0/26)       |        | (10.1.2.0/24)       |
+---------------------+        +---------------------+
| Gateway Subnet      |        | Data Subnet         |
| (future)            |        | (10.1.3.0/24)       |
+---------------------+        +---------------------+
```

## Resources Created

- **Hub Virtual Network**: Central connectivity point for shared services
- **Spoke Virtual Network**: Workload-specific network
- **VNet Peering**: Bidirectional peering between hub and spoke
- **Subnets**: Segregated by tier (management, web, app, data)
- **Network Security Groups**: Deny-by-default rules per subnet
- **Azure Bastion**: Secure VM access without public IPs (optional)

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  environment             = "dev"
  location                = "eastus"
  resource_group_name     = azurerm_resource_group.main.name
  hub_vnet_address_space  = ["10.0.0.0/16"]
  spoke_vnet_address_space = ["10.1.0.0/16"]
  enable_bastion          = true

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
| resource_group_name | Name of the resource group | string | n/a | yes |
| hub_vnet_address_space | Hub VNet address space (CIDR) | list(string) | n/a | yes |
| spoke_vnet_address_space | Spoke VNet address space (CIDR) | list(string) | n/a | yes |
| mgmt_subnet_prefix | Management subnet prefix | string | "10.0.1.0/24" | no |
| bastion_subnet_prefix | Bastion subnet prefix (min /26) | string | "10.0.2.0/26" | no |
| web_subnet_prefix | Web tier subnet prefix | string | "10.1.1.0/24" | no |
| app_subnet_prefix | App tier subnet prefix | string | "10.1.2.0/24" | no |
| data_subnet_prefix | Data tier subnet prefix | string | "10.1.3.0/24" | no |
| enable_bastion | Enable Azure Bastion | bool | true | no |
| enable_vnet_peering | Enable hub-spoke VNet peering | bool | true | no |
| tags | Tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| hub_vnet_id | Resource ID of the hub virtual network |
| hub_vnet_name | Name of the hub virtual network |
| spoke_vnet_id | Resource ID of the spoke virtual network |
| spoke_vnet_name | Name of the spoke virtual network |
| subnet_ids | Map of subnet names to resource IDs |
| app_nsg_id | Resource ID of the application subnet NSG |
| bastion_host_id | Resource ID of the Azure Bastion host |

## Dependencies

- **landing-zone**: Requires resource group from the landing zone module

## Next Steps

- Implement hub and spoke VNets
- Configure VNet peering
- Create NSG rules with least-privilege access
- Add Azure Bastion for secure VM access
- Configure route tables for custom routing
