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
