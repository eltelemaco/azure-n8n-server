variable "tfc_organization" {
  description = "HCP Terraform organization name."
  type        = string
  default     = "TelemacoInfraLabs"
}

variable "tfc_project_name" {
  description = "Optional HCP Terraform project name."
  type        = string
  default     = "azure-hcp-project"
}

variable "tfc_workspace_name" {
  description = "HCP Terraform workspace name (e.g., n8n-prod-usw1)."
  type        = string
  default     = "azure-n8n-server"
}

variable "tfc_working_directory" {
  description = "Working directory for the HCP Terraform workspace."
  type        = string
  default     = "infra/environments/dev"
}

variable "vcs_repo_identifier" {
  description = "Optional VCS repo identifier (org/name) to connect workspace."
  type        = string
  default     = null
}

variable "vcs_repo_branch" {
  description = "Optional VCS branch name for the workspace."
  type        = string
  default     = null
}

variable "vcs_oauth_token_id" {
  description = "Optional VCS OAuth token ID (required if vcs_repo_identifier is set)."
  type        = string
  default     = null

  validation {
    condition     = var.vcs_repo_identifier == null || var.vcs_oauth_token_id != null
    error_message = "vcs_oauth_token_id is required when vcs_repo_identifier is set."
  }
}

variable "location" {
  description = "Primary Azure region for resource deployment."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging."
  type        = string
  default     = "azure-landing-zone"
}

variable "owner" {
  description = "Resource owner for tagging and accountability."
  type        = string
  default     = "team-infrastructure"
}

variable "cost_center" {
  description = "Cost center identifier for billing allocation."
  type        = string
  default     = "IT-001"
}

variable "hub_vnet_address_space" {
  description = "Address space for the hub virtual network in CIDR notation."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_vnet_address_space" {
  description = "Address space for the spoke virtual network in CIDR notation."
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "vm_size" {
  description = "Azure VM size (SKU) for compute instances."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Administrator username for VM instances."
  type        = string
  default     = "telemaco"

  validation {
    condition     = !contains(["admin", "administrator", "root"], var.admin_username)
    error_message = "Admin username must not be 'admin', 'administrator', or 'root'."
  }
}

variable "vm_instance_count" {
  description = "Number of VM instances to deploy in the environment."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_instance_count >= 1 && var.vm_instance_count <= 10
    error_message = "VM instance count must be between 1 and 10."
  }
}

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access (no public IPs)."
  type        = bool
  default     = true
}

variable "enable_key_vault" {
  description = "Enable Azure Key Vault for secrets management."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Log Analytics workspace."
  type        = bool
  default     = true
}

variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for compliance enforcement."
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Additional custom tags to merge with common tags on all resources."
  type        = map(string)
  default     = {}
}

variable "azure_github_app_id" {
  description = "Azure GitHub App ID for integrations."
  type        = string
  sensitive   = true
}

variable "azure_hcp_app_id" {
  description = "Azure HCP App ID for integrations."
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID for provider auth and integrations."
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure subscription ID for provider auth and billing."
  type        = string
  sensitive   = true
}
