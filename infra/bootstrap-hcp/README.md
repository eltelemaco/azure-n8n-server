# Bootstrap HCP Terraform

Creates the HCP Terraform workspace and seeds required variables for the Azure
landing zone stack. This directory uses local state.

## Prerequisites

- Terraform CLI
- HCP Terraform organization + API token in environment variable `TFE_TOKEN`

## Usage

1) Initialize and apply:

- `terraform init`
- `terraform apply`

2) Provide required variables via `-var` or `TF_VAR_` environment variables:

- `tfc_organization`, `tfc_workspace_name`
- `location`, `project_name`, `owner`, `cost_center`
- Secrets: `arm_subscription_id`, `arm_tenant_id`, `tfc_azure_run_client_id`

## Notes

- Secrets are marked sensitive and are not stored in the repo.
- This module assumes the HCP Terraform project and workspace already exist.
- HCP workspace environment variables include `ARM_SUBSCRIPTION_ID`,
    `ARM_TENANT_ID`, `TFC_AZURE_PROVIDER_AUTH`, and `TFC_AZURE_RUN_CLIENT_ID`.
- For federated credentials in Entra ID, create two entries (plan/apply) with
    subjects:
    - `organization:TelemacoInfraLabs:project:azure-hcp-project:workspace:azure-n8n-server:run_phase:plan`
    - `organization:TelemacoInfraLabs:project:azure-hcp-project:workspace:azure-n8n-server:run_phase:apply`
    Use the issuer URL exactly as provided by HCP Terraform (no trailing slash).
