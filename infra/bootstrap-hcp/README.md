# Bootstrap HCP Terraform

Creates the HCP Terraform workspace and seeds required variables for the Azure
landing zone stack. This directory uses local state.

## Prerequisites

- Terraform CLI
- HCP Terraform organization + API token in environment variable `TFE_TOKEN`

## Usage

1) Initialize and apply:`

```hcl
- `terraform init`
- `terraform apply`
```

2) Provide required variables via `-var` or `TF_VAR_` environment variables:

```hcl
- `tfc_organization`, `tfc_workspace_name`, `tfc_working_directory`
- `location`, `project_name`, `owner`, `cost_center`
- Secrets: `azure_github_app_id`, `azure_hcp_app_id`, `azure_tenant_id`, `azure_subscription_id`
```

## Notes

- Secrets are marked sensitive and are not stored in the repo.
- If using VCS-driven runs, set `vcs_repo_identifier` and `vcs_oauth_token_id`.
