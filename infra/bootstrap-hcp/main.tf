provider "tfe" {}

data "tfe_workspace" "this" {
  name         = var.tfc_workspace_name
  organization = var.tfc_organization
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
    ARM_TENANT_ID = {
      value     = var.arm_tenant_id
      sensitive = true
    }
    ARM_SUBSCRIPTION_ID = {
      value     = var.arm_subscription_id
      sensitive = true
    }
    TFC_AZURE_PROVIDER_AUTH = {
      value     = tostring(var.tfc_azure_provider_auth)
      sensitive = false
    }
    TFC_AZURE_RUN_CLIENT_ID = {
      value     = var.tfc_azure_run_client_id
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
  workspace_id = data.tfe_workspace.this.id
  key          = each.key
  value        = each.value.value
  category     = "terraform"
  sensitive    = each.value.sensitive
  hcl          = each.value.hcl
}

resource "tfe_variable" "env" {
  for_each     = nonsensitive(local.env_vars_filtered)
  workspace_id = data.tfe_workspace.this.id
  key          = each.key
  value        = each.value.value
  category     = "env"
  sensitive    = each.value.sensitive
  hcl          = false
}
