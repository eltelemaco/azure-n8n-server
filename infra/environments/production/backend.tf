# -----------------------------------------------------------------------------
# backend.tf - HCP Terraform Backend Configuration (Production)
# -----------------------------------------------------------------------------
# Purpose: Configures remote state storage and execution via HCP Terraform
# for the production environment.
#
# The production workspace should have:
#   - Strict access controls (limited team members)
#   - Mandatory plan approval before apply
#   - Sentinel policies for compliance enforcement (if available)
#   - VCS integration with protected branch (main/production)
#   - Notification integrations for apply events
#
# Prerequisites:
#   - HCP Terraform account with organization created
#   - API token configured via `terraform login` or TF_TOKEN_app_terraform_io
#   - Workspace created with appropriate access controls
#   - Azure service principal with production subscription permissions
#
# Next steps:
#   - Replace "your-org-name" with your HCP Terraform organization
#   - Create the workspace with auto-apply DISABLED
#   - Configure mandatory plan review in workspace settings
#   - Set up notification integrations (Slack, email, etc.)
#   - Configure run triggers from staging workspace (optional)
# -----------------------------------------------------------------------------

terraform {
  cloud {
    # TODO: Replace with your HCP Terraform organization name
    organization = "your-org-name"

    workspaces {
      # Workspace naming convention: <project>-<environment>
      name = "azure-landing-zone-production"
    }
  }
}
