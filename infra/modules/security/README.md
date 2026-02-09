# Security Module

## Overview

The security module implements security infrastructure for the Azure landing zone, providing centralized secrets management, identity management, and policy-driven compliance enforcement.

## Resources Created

- **Azure Key Vault**: Centralized storage for secrets, keys, and certificates with RBAC authorization
- **Managed Identities**: User-assigned identities for Azure resource access
- **RBAC Assignments**: Least-privilege role assignments for Key Vault access
- **Key Vault Secrets**: Auto-generated VM admin password stored securely
- **Diagnostic Settings**: Key Vault audit logging to Log Analytics

## Security Principles

- Secrets are stored in Key Vault, never in Terraform state or source code
- Managed identities are preferred over service principals
- RBAC authorization mode (not access policies) for Key Vault
- Network restrictions applied in production (private endpoint recommended)
- Soft delete and purge protection enabled for data recovery
- All Key Vault operations are audited via diagnostic settings

## Usage

```hcl
module "security" {
  source = "../../modules/security"

  environment         = "dev"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  enable_key_vault    = true

  log_analytics_workspace_id = module.landing_zone.log_analytics_workspace_id

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
| enable_key_vault | Enable Azure Key Vault | bool | true | no |
| key_vault_sku | Key Vault SKU (standard or premium) | string | "standard" | no |
| soft_delete_retention_days | Days to retain soft-deleted items | number | 90 | no |
| log_analytics_workspace_id | Log Analytics workspace for diagnostics | string | "" | no |
| tags | Tags for all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | Resource ID of the Azure Key Vault |
| key_vault_name | Name of the Azure Key Vault |
| key_vault_uri | URI of the Azure Key Vault |
| vm_identity_id | Resource ID of the VM managed identity |
| vm_identity_principal_id | Principal ID of the VM managed identity |
| vm_identity_client_id | Client ID of the VM managed identity |
| vm_admin_password_secret_id | Key Vault secret ID for VM admin password |

## Dependencies

- **landing-zone**: Requires Log Analytics workspace ID for diagnostic settings

## Next Steps

- Implement Key Vault with RBAC authorization
- Create managed identity for VM access
- Configure Key Vault diagnostic settings
- Add private endpoint for Key Vault in production
- Define Azure Policy for compliance enforcement
