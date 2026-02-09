# -----------------------------------------------------------------------------
# main.tf - Production Environment Root Module
# -----------------------------------------------------------------------------
# Purpose: Root module for the production environment. Orchestrates all
# infrastructure modules with production-grade configuration including
# high availability, disaster recovery, and strict compliance.
#
# IMPORTANT: Changes to production require:
#   1. Successful deployment in staging environment
#   2. Terraform plan review and explicit approval
#   3. Change management approval (if applicable)
#
# Conventions:
#   - Resource naming: <type>-production-<location>-<name>
#   - All resources tagged with environment = "production"
#   - Uses hub-and-spoke network topology with full redundancy
#   - Resource locks applied to prevent accidental deletion
#
# Next steps:
#   - Wire up module calls with production-grade variable values
#   - Add lifecycle blocks with prevent_destroy for critical resources
#   - Configure Azure Monitor alerts for production SLAs
#   - Enable Azure Site Recovery for disaster recovery
# -----------------------------------------------------------------------------

locals {
  environment = "production"
  location    = var.location
  project     = var.project_name

  # Common tags applied to all resources in this environment
  common_tags = {
    environment = local.environment
    managed_by  = "terraform"
    project     = local.project
    owner       = var.owner
    cost_center = var.cost_center
  }
}

# --- Resource Group ----------------------------------------------------------
# Primary resource group for the production landing zone
# Naming convention: rg-<environment>-<location>-<name>

# TODO: Uncomment and configure when azurerm provider is initialized
# resource "azurerm_resource_group" "main" {
#   name     = "rg-${local.environment}-${local.location}-landing-zone"
#   location = local.location
#   tags     = local.common_tags
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# --- Landing Zone Module ----------------------------------------------------

# TODO: Configure landing-zone module with production-grade values
# module "landing_zone" {
#   source = "../../modules/landing-zone"
#
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   tags                = local.common_tags
# }

# --- Networking Module -------------------------------------------------------

# TODO: Configure networking module with production address spaces and redundancy
# module "networking" {
#   source = "../../modules/networking"
#
#   environment             = local.environment
#   location                = local.location
#   resource_group_name     = azurerm_resource_group.main.name
#   hub_vnet_address_space  = var.hub_vnet_address_space
#   spoke_vnet_address_space = var.spoke_vnet_address_space
#   tags                    = local.common_tags
# }

# --- Security Module ---------------------------------------------------------

# TODO: Configure security module with production compliance policies
# module "security" {
#   source = "../../modules/security"
#
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   enable_key_vault    = var.enable_key_vault
#   tags                = local.common_tags
# }

# --- Compute Module ----------------------------------------------------------

# TODO: Configure compute module with production VM sizes and HA
# module "compute" {
#   source = "../../modules/compute"
#
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   subnet_id           = module.networking.subnet_ids["app"]
#   vm_size             = var.vm_size
#   admin_username      = var.admin_username
#   vm_instance_count   = var.vm_instance_count
#   tags                = local.common_tags
#
#   depends_on = [module.networking, module.security]
# }

# --- Governance Module -------------------------------------------------------

# TODO: Configure governance module with production compliance requirements
# module "governance" {
#   source = "../../modules/governance"
#
#   environment              = local.environment
#   enable_policy_assignments = var.enable_policy_assignments
#   tags                     = local.common_tags
# }

# --- Resource Locks ----------------------------------------------------------
# Production resources should have delete locks to prevent accidental removal

# TODO: Add resource locks for critical production resources
# resource "azurerm_management_lock" "rg_lock" {
#   name       = "lock-${local.environment}-rg-nodelete"
#   scope      = azurerm_resource_group.main.id
#   lock_level = "CanNotDelete"
#   notes      = "Production resource group - cannot be deleted without removing lock"
# }
