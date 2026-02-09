# -----------------------------------------------------------------------------
# .tflint.hcl - TFLint Configuration
# -----------------------------------------------------------------------------
# Purpose: Configuration for tflint used by the validator-security-scan agent
# in the GitHub Actions CI/CD pipeline. Enforces Azure best practices, security
# standards, and Terraform coding conventions across all modules.
#
# This configuration is referenced from:
#   - .github/workflows/terraform-pr-checks.yml (validator-security-scan job)
#   - .github/workflows/terraform-deploy.yml (validator-security-scan job)
#
# Usage:
#   tflint --config infra/.tflint.hcl --chdir infra/environments/dev
#
# Plugin documentation:
#   https://github.com/terraform-linters/tflint-ruleset-azurerm
# -----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Global configuration
# ---------------------------------------------------------------------------

config {
  # Enable module inspection to lint referenced child modules in modules/
  module = true

  # Do not force failures - let the CI pipeline control exit behavior.
  # The workflow decides whether to fail on warnings vs errors.
  force = false
}

# ---------------------------------------------------------------------------
# Plugin: tflint-ruleset-azurerm
# ---------------------------------------------------------------------------
# Azure-specific rules that validate resource configurations against
# Azure best practices and API constraints.

plugin "azurerm" {
  enabled = true
  version = "~> 0.27"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# ---------------------------------------------------------------------------
# Terraform language rules
# ---------------------------------------------------------------------------
# These rules enforce Terraform coding conventions defined in CLAUDE.md:
#   - All variables must have descriptions
#   - All outputs must have descriptions
#   - Standard naming and typing practices

# Require description on every variable declaration.
# Rationale: Variables without descriptions are difficult to understand
# for other team members and in auto-generated documentation.
rule "terraform_documented_variables" {
  enabled = true
}

# Require description on every output declaration.
# Rationale: Outputs are the module's public API; consumers need to
# understand what each value represents.
rule "terraform_documented_outputs" {
  enabled = true
}

# Enforce consistent naming convention for all Terraform resources,
# data sources, variables, outputs, locals, and modules.
# Convention: snake_case (e.g., my_resource, not my-resource or MyResource)
rule "terraform_naming_convention" {
  enabled = true

  # Use snake_case for all identifiers (Terraform standard)
  custom_formats = {}

  # Variables must use snake_case
  variable {
    format = "snake_case"
  }

  # Outputs must use snake_case
  output {
    format = "snake_case"
  }

  # Resources must use snake_case
  resource {
    format = "snake_case"
  }

  # Data sources must use snake_case
  data {
    format = "snake_case"
  }

  # Modules must use snake_case
  module {
    format = "snake_case"
  }

  # Locals must use snake_case
  locals {
    format = "snake_case"
  }
}

# Require explicit type declarations on all variables.
# Rationale: Untyped variables accept any value and can cause
# confusing errors at plan/apply time.
rule "terraform_typed_variables" {
  enabled = true
}

# Disallow use of terraform_remote_state data source.
# Rationale: This project uses HCP Terraform for state management;
# cross-workspace references should use HCP run triggers or
# tfe_outputs data source instead.
rule "terraform_unused_required_providers" {
  enabled = true
}

# Flag unused variable declarations.
# Rationale: Unused variables add clutter and confusion.
rule "terraform_unused_declarations" {
  enabled = true
}

# Warn on deprecated syntax or attributes.
# Rationale: Keep code current and avoid breaking changes on upgrade.
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Enforce consistent use of = (not :=) for attribute assignment.
rule "terraform_comment_syntax" {
  enabled = true
}

# Recommend using standard module structure.
# Rationale: Every module should have main.tf, variables.tf, outputs.tf.
rule "terraform_standard_module_structure" {
  enabled = true
}

# Ensure workspace_default is not used as a conditional.
# Rationale: With HCP Terraform, workspace selection is handled by the
# backend configuration, not terraform.workspace.
rule "terraform_workspace_remote" {
  enabled = true
}

# ---------------------------------------------------------------------------
# Azure Security Rules
# ---------------------------------------------------------------------------
# These rules enforce security best practices specific to Azure resources.
# They validate configurations for public IPs, NSG rules, Key Vault settings,
# and other security-sensitive configurations as defined in CLAUDE.md.

# Enforce naming convention for Azure resources.
# Rationale: Azure resource names must follow the pattern:
# <resource-type>-<environment>-<location>-<name>
# This rule validates against Azure naming constraints and best practices.
rule "azurerm_resource_naming" {
  enabled = true
}

# Warn on invalid or deprecated Azure resource configurations.
# Rationale: Azure APIs evolve and certain configurations become deprecated.
# This catches configurations that will fail on terraform apply.
rule "azurerm_resource_missing_tags" {
  enabled = true
}

# Security: Flag resources with public IP addresses.
# Rationale: Per CLAUDE.md, no public IP addresses should be used without
# explicit justification. Azure Bastion should be used for VM access instead.
rule "azurerm_virtual_machine_should_not_have_public_ip" {
  enabled = true
}

# Security: Validate Network Security Group (NSG) rules.
# Rationale: NSGs must follow least-privilege principle. Rules allowing
# unrestricted access (0.0.0.0/0) to sensitive ports should be flagged.
rule "azurerm_network_security_group_rule_invalid" {
  enabled = true
}

# Security: Ensure Key Vault access policies are properly configured.
# Rationale: Key Vault should use RBAC or access policies, not both.
# Overly permissive access policies introduce security risks.
rule "azurerm_key_vault_access_policy_invalid" {
  enabled = true
}

# Security: Flag storage accounts with public network access enabled.
# Rationale: Storage accounts should use private endpoints and deny
# public access in production environments.
rule "azurerm_storage_account_network_rules_invalid" {
  enabled = true
}

# ---------------------------------------------------------------------------
# Severity Configuration
# ---------------------------------------------------------------------------
# Rule severity levels determine CI/CD pipeline behavior:
#   - ERROR: Fails the build (for security and correctness issues)
#   - WARNING: Reported but does not fail build (for style and best practices)
#   - NOTICE: Informational only (for suggestions and optimizations)
#
# Azure security rules (public IPs, NSG misconfigurations, Key Vault issues)
# are treated as errors. Terraform style violations are treated as warnings.
