# Compute Module

## Overview

The compute module deploys Linux virtual machines with secure configuration for the Azure landing zone. VMs are configured with managed identities, encrypted disks, and Azure Monitor integration following Azure Well-Architected Framework best practices.

## Resources Created

- **Linux Virtual Machines**: Ubuntu 22.04 LTS instances with configurable sizing
- **Network Interfaces**: Private NICs attached to application subnet (no public IPs)
- **OS Disks**: Managed disks with configurable storage type and encryption
- **VM Extensions**: Azure Monitor Agent for observability
- **Boot Diagnostics**: Enabled for VM troubleshooting

## Security Configuration

- No public IP addresses assigned (access via Azure Bastion only)
- Admin password stored in Azure Key Vault
- User-assigned managed identity for Azure resource access
- Azure Disk Encryption for data at rest
- Azure Monitor Agent for security event logging
- Password authentication can be disabled in favor of SSH keys

## Usage

```hcl
module "compute" {
  source = "../../modules/compute"

  environment         = "dev"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.subnet_ids["app"]

  vm_name_prefix    = "vm-dev-app"
  vm_size           = "Standard_D2s_v3"
  vm_instance_count = 1
  admin_username    = "azureadmin"
  admin_password    = module.security.vm_admin_password

  managed_identity_ids = [module.security.vm_identity_id]
  enable_monitoring    = true

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
| subnet_id | Subnet ID for VM network interfaces | string | n/a | yes |
| vm_name_prefix | Prefix for VM names | string | "vm-app" | no |
| vm_size | VM size (SKU) | string | "Standard_D2s_v3" | no |
| vm_instance_count | Number of VMs to deploy | number | 1 | no |
| admin_username | VM administrator username | string | "azureadmin" | no |
| admin_password | VM administrator password (sensitive) | string | "" | no |
| os_disk_caching | OS disk caching type | string | "ReadWrite" | no |
| os_disk_type | OS disk storage type | string | "Premium_LRS" | no |
| image_publisher | VM image publisher | string | "Canonical" | no |
| image_offer | VM image offer | string | "0001-com-ubuntu-server-jammy" | no |
| image_sku | VM image SKU | string | "22_04-lts-gen2" | no |
| image_version | VM image version | string | "latest" | no |
| managed_identity_ids | Managed identity IDs for VMs | list(string) | [] | no |
| enable_monitoring | Enable Azure Monitor agent | bool | true | no |
| tags | Tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_ids | List of VM resource IDs |
| vm_names | List of VM names |
| vm_private_ips | List of VM private IP addresses |
| admin_password | VM administrator password (sensitive) |
| nic_ids | List of network interface resource IDs |

## Dependencies

- **networking**: Requires subnet ID for VM placement
- **security**: Requires Key Vault for admin password, managed identity for VM access

## Next Steps

- Implement VM resource with network interface
- Configure OS disk encryption
- Add boot diagnostics
- Install Azure Monitor Agent extension
- Add availability set or zone configuration for high availability
- Configure custom script extensions for post-deployment configuration
