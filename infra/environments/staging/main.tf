# -----------------------------------------------------------------------------
# main.tf - Staging Environment Root Module
# -----------------------------------------------------------------------------
# Purpose: Root module for the staging environment. Orchestrates all
# infrastructure modules (landing-zone, networking, security, compute,
# governance) with staging-specific configuration.
#
# The staging environment mirrors production topology with reduced capacity
# for pre-release validation and integration testing.
#
# Conventions:
#   - Resource naming: <type>-staging-<location>-<name>
#   - All resources tagged with environment = "staging"
#   - Uses hub-and-spoke network topology (matching production)
#
# Next steps:
#   - Wire up module calls with staging-specific variable values
#   - Configure module dependencies using depends_on where needed
#   - Ensure network address spaces do not overlap with dev or production
# -----------------------------------------------------------------------------

locals {
  environment = "staging"
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
# Primary resource group for the staging landing zone
# Naming convention: rg-<environment>-<location>-<name>

# TODO: Uncomment and configure when azurerm provider is initialized
# resource "azurerm_resource_group" "main" {
#   name     = "rg-${local.environment}-${local.location}-landing-zone"
#   location = local.location
#   tags     = local.common_tags
# }

# --- Landing Zone Module ----------------------------------------------------

# TODO: Configure landing-zone module with staging-specific values
# module "landing_zone" {
#   source = "../../modules/landing-zone"
#
#   environment         = local.environment
#   location            = local.location
#   resource_group_name = azurerm_resource_group.main.name
#   tags                = local.common_tags
# }

# --- Networking Module -------------------------------------------------------

# TODO: Configure networking module with staging address spaces
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

# TODO: Configure security module with staging policies
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

# TODO: Configure compute module with staging VM sizes
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

# TODO: Configure governance module with staging compliance rules
# module "governance" {
#   source = "../../modules/governance"
#
#   environment              = local.environment
#   enable_policy_assignments = var.enable_policy_assignments
#   tags                     = local.common_tags
# }
