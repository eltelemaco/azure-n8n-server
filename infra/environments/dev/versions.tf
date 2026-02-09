# -----------------------------------------------------------------------------
# versions.tf - Provider Version Constraints
# -----------------------------------------------------------------------------
# Purpose: Defines the required Terraform version and provider version
# constraints for the Azure Landing Zone project.
#
# This file ensures consistent provider versions across all environments
# and team members. The dependency lock file (.terraform.lock.hcl) further
# pins exact versions after `terraform init`.
#
# Conventions:
#   - Terraform version >= 1.9.0 (required for HCP Terraform cloud block)
#   - Azure provider (azurerm) pinned to ~> 4.0 for stability
#   - All providers use pessimistic version constraints (~>)
#
# Next steps:
#   - Update provider versions as new releases are validated
#   - Add additional providers as needed (azuread, random, tls, etc.)
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    # Azure Resource Manager provider
    # Documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    # Azure Active Directory provider (for RBAC and identity management)
    # Documentation: https://registry.terraform.io/providers/hashicorp/azuread/latest
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }

    # Random provider (for generating unique names, passwords, etc.)
    # Documentation: https://registry.terraform.io/providers/hashicorp/random/latest
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    # TLS provider (for generating SSH keys and certificates)
    # Documentation: https://registry.terraform.io/providers/hashicorp/tls/latest
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
