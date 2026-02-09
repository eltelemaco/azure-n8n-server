# -----------------------------------------------------------------------------
# backend.tf - HCP Terraform Backend Configuration (Dev)
# -----------------------------------------------------------------------------
# Purpose: Configures remote state storage and execution via HCP Terraform
# (formerly Terraform Cloud) for the dev environment.
#
# HCP Terraform provides:
#   - Remote state storage with encryption at rest
#   - Automatic state locking to prevent concurrent modifications
#   - Run history and audit trail
#   - Workspace-level variable management
#   - VCS-driven or CLI-driven workflow support
#
# Prerequisites:
#   - HCP Terraform account with organization created
#   - API token configured via `terraform login` or TF_TOKEN_app_terraform_io
#   - Workspace created in HCP Terraform matching the name below
#
# Next steps:
#   - Replace "your-org-name" with your HCP Terraform organization
#   - Create the workspace in HCP Terraform before running terraform init
#   - Configure workspace variables for Azure OIDC credentials
#     (ARM_USE_OIDC, ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)
# -----------------------------------------------------------------------------

terraform {
  cloud {
    # TODO: Replace with your HCP Terraform organization name
    organization = "TelemacoInfraLabs"

    workspaces {
      # Workspace naming convention: <project>-<environment>
      name = "azure-n8n-server"
    }
  }
}
