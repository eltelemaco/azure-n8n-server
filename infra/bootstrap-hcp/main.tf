terraform {
  required_version = ">= 1.6.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50"
    }
  }
}

provider "tfe" {}

resource "tfe_project" "this" {
  count        = var.tfc_project_name == null ? 0 : 1
  name         = var.tfc_project_name
  organization = var.tfc_organization
}

resource "tfe_workspace" "this" {
  name              = var.tfc_workspace_name
  organization      = var.tfc_organization
  project_id        = var.tfc_project_name == null ? null : tfe_project.this[0].id
  working_directory = var.tfc_working_directory
  auto_apply        = false

  dynamic "vcs_repo" {
    for_each = var.vcs_repo_identifier == null ? [] : [var.vcs_repo_identifier]
    content {
      identifier     = vcs_repo.value
      branch         = var.vcs_repo_branch
      oauth_token_id = var.vcs_oauth_token_id
    }
  }
}

locals {
  terraform_vars = {
    location = {
      value     = jsonencode(var.location)
      sensitive = false
      hcl       = true
    }
    project_name = {
      value     = jsonencode(var.project_name)
      sensitive = false
      hcl       = true
    }
    owner = {
      value     = jsonencode(var.owner)
      sensitive = false
      hcl       = true
    }
    cost_center = {
      value     = jsonencode(var.cost_center)
      sensitive = false
      hcl       = true
    }
    hub_vnet_address_space = {
      value     = jsonencode(var.hub_vnet_address_space)
      sensitive = false
      hcl       = true
    }
    spoke_vnet_address_space = {
      value     = jsonencode(var.spoke_vnet_address_space)
      sensitive = false
      hcl       = true
    }
    vm_size = {
      value     = jsonencode(var.vm_size)
      sensitive = false
      hcl       = true
    }
    admin_username = {
      value     = jsonencode(var.admin_username)
      sensitive = false
      hcl       = true
    }
    vm_instance_count = {
      value     = jsonencode(var.vm_instance_count)
      sensitive = false
      hcl       = true
    }
    enable_bastion = {
      value     = jsonencode(var.enable_bastion)
      sensitive = false
      hcl       = true
    }
    enable_key_vault = {
      value     = jsonencode(var.enable_key_vault)
      sensitive = false
      hcl       = true
    }
    enable_monitoring = {
      value     = jsonencode(var.enable_monitoring)
      sensitive = false
      hcl       = true
    }
    enable_policy_assignments = {
      value     = jsonencode(var.enable_policy_assignments)
      sensitive = false
      hcl       = true
    }
    extra_tags = {
      value     = jsonencode(var.extra_tags)
      sensitive = false
      hcl       = true
    }
  }

  env_vars = {
    AZURE_GITHUB_APP_ID = {
      value     = var.azure_github_app_id
      sensitive = true
    }
    AZURE_HCP_APP_ID = {
      value     = var.azure_hcp_app_id
      sensitive = true
    }
    AZURE_TENANT_ID = {
      value     = var.azure_tenant_id
      sensitive = true
    }
    AZURE_SUBSCRIPTION_ID = {
      value     = var.azure_subscription_id
      sensitive = true
    }
  }

  terraform_vars_filtered = {
    for key, item in local.terraform_vars : key => item
    if nonsensitive(item.value) != null && nonsensitive(item.value) != ""
  }

  env_vars_filtered = {
    for key, item in local.env_vars : key => item
    if nonsensitive(item.value) != null && nonsensitive(item.value) != ""
  }
}

resource "tfe_variable" "terraform" {
  for_each     = nonsensitive(local.terraform_vars_filtered)
  workspace_id = tfe_workspace.this.id
  key          = each.key
  value        = each.value.value
  category     = "terraform"
  sensitive    = each.value.sensitive
  hcl          = each.value.hcl
}

resource "tfe_variable" "env" {
  for_each     = nonsensitive(local.env_vars_filtered)
  workspace_id = tfe_workspace.this.id
  key          = each.key
  value        = each.value.value
  category     = "env"
  sensitive    = each.value.sensitive
  hcl          = false
}
