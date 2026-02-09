# -----------------------------------------------------------------------------
# versions.tf - Provider Version Constraints
# -----------------------------------------------------------------------------
# Purpose: Defines the required Terraform version and provider version
# constraints for the HCP Terraform bootstrap stack.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50"
    }
  }
}
