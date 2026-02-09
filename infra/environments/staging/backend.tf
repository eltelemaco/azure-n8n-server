# -----------------------------------------------------------------------------
# backend.tf - HCP Terraform Backend Configuration (Staging)
# -----------------------------------------------------------------------------
# Purpose: Configures remote state storage and execution via HCP Terraform
# for the staging environment.
#
# The staging workspace should have:
#   - Separate Azure credentials from dev and production
#   - Approval policies for plan/apply (recommended)
#   - VCS integration for PR-based infrastructure changes
#
# Prerequisites:
#   - HCP Terraform account with organization created
#   - API token configured via `terraform login` or TF_TOKEN_app_terraform_io
#   - Workspace created in HCP Terraform matching the name below
#
# Next steps:
#   - Replace "your-org-name" with your HCP Terraform organization
#   - Create the workspace in HCP Terraform
#   - Configure workspace variable sets for Azure credentials
#   - Set up run triggers from dev workspace (optional)
# -----------------------------------------------------------------------------

terraform {
  cloud {
    # TODO: Replace with your HCP Terraform organization name
    organization = "your-org-name"

    workspaces {
      # Workspace naming convention: <project>-<environment>
      name = "azure-landing-zone-staging"
    }
  }
}
