# -----------------------------------------------------------------------------
# main.tf - Dev Environment Root Module
# -----------------------------------------------------------------------------
# Purpose: Root module for the development environment. Orchestrates all
# infrastructure modules (landing-zone, networking, security, compute,
# governance) with dev-specific configuration.
#
# This file composes the reusable modules from modules/ to create the
# complete dev environment infrastructure.
#
# Conventions:
#   - Resource naming: <type>-dev-<location>-<name>
#   - All resources tagged with environment = "dev"
#   - Uses hub-and-spoke network topology
#
# Next steps:
#   - Wire up module calls with appropriate variable values
#   - Configure module dependencies using depends_on where needed
#   - Add data sources for existing Azure resources
# -----------------------------------------------------------------------------

locals {
  environment = "dev"
  location    = var.location
  project     = var.project_name

  # Common tags applied to all resources in this environment
  # See CLAUDE.md tagging strategy for required tags
  common_tags = {
    environment = local.environment
    managed_by  = "terraform"
    project     = local.project
    owner       = var.owner
    cost_center = var.cost_center
  }
}

# --- Resource Group ----------------------------------------------------------
# Primary resource group for the dev landing zone
# Naming convention: rg-<environment>-<location>-<name>

# TODO: Uncomment and configure when azurerm provider is initialized
# resource "azurerm_resource_group" "main" {
#   name     = "rg-${local.environment}-${local.location}-landing-zone"
#   location = local.location
#   tags     = local.common_tags
# }

# --- Landing Zone Module ----------------------------------------------------
# Core landing zone module providing foundational infrastructure

# TODO: Configure landing-zone module with dev-specific values
# module "landing_zone" {
#   source = "../../modules/landing-zone"
#
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   tags                = local.common_tags
# }

# --- Networking Module -------------------------------------------------------
# Hub-and-spoke virtual network topology

# TODO: Configure networking module with dev address spaces
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
# Azure Policy, RBAC, and Key Vault configuration

# TODO: Configure security module
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
# VM instances with Azure Bastion access

# TODO: Configure compute module with dev VM sizes
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
# Management groups, policy assignments, and compliance

# TODO: Configure governance module
# module "governance" {
#   source = "../../modules/governance"
#
#   environment              = local.environment
#   enable_policy_assignments = var.enable_policy_assignments
#   tags                     = local.common_tags
# }
