# Plan: Infrastructure Reorganization and HCP Bootstrap Automation

## Task Description

Reorganize the Azure Landing Zone Terraform infrastructure by moving all Infrastructure-as-Code (IaC) files into a dedicated `infra/` directory to improve project structure and separation of concerns. Additionally, implement a one-time bootstrap automation to provision the HCP Terraform infrastructure including project creation, workspace setup, variable configuration, and secret management. This bootstrap process simplifies initial setup and ensures consistent HCP configuration across team members.

## Objective

1. **Refactor Directory Structure**: Move all Terraform-related files (`environments/`, `modules/`, `versions.tf`, `terraform.tfvars.example`) into a new `infra/` directory while preserving functionality and maintaining clean separation from orchestration framework files (`.claude/`, `pyproject.toml`, etc.)

2. **Create HCP Bootstrap**: Implement a standalone Terraform bootstrap module that runs once during initial setup to:
   - Create HCP Terraform project and organization structure
   - Provision environment-specific workspaces (dev, staging, production)
   - Configure workspace variables (environment names, locations, sizes)
   - Set up sensitive variables and secrets (Azure credentials, subscription IDs)
   - Generate outputs for use in main infrastructure code

## Problem Statement

The current project structure mixes infrastructure code with orchestration framework files at the root level, making it difficult to:

- Distinguish IaC from tooling/automation code
- Apply different CI/CD pipelines to infrastructure vs. orchestration
- Scale the project with additional non-IaC components (apps, scripts, documentation)

Additionally, HCP Terraform setup requires manual configuration through the web UI for:

- Creating projects and workspaces
- Setting workspace variables individually
- Configuring Azure authentication environment variables
- Managing secrets across multiple environments

This manual process is error-prone, time-consuming, and lacks version control or reproducibility.

## Solution Approach

### Directory Reorganization Strategy

1. **Create `infra/` Root**: Establish new top-level `infra/` directory as the container for all Terraform code
2. **Move IaC Files**: Relocate `environments/`, `modules/`, `versions.tf`, `terraform.tfvars.example`, and `README.md` (renamed to `infra/README.md`) into `infra/`
3. **Update References**: Modify all Terraform module source paths to reflect new structure (e.g., `../../modules/networking` becomes `../modules/networking`)
4. **Update Documentation**: Revise root `README.md` and `.claude/CLAUDE.md` to document new structure and update directory trees
5. **Preserve Git History**: Use `git mv` commands to maintain file history during reorganization
6. **Update Backend Paths**: Ensure HCP Terraform backend configurations reference correct working directories

### HCP Bootstrap Automation Strategy

1. **Bootstrap Module Design**: Create `infra/bootstrap/` directory containing:
   - `main.tf` - HCP Terraform provider and resources (projects, workspaces, variables)
   - `variables.tf` - Bootstrap configuration inputs (org name, workspace names, Azure credentials)
   - `outputs.tf` - Generated values (workspace IDs, organization name) for use in main infra
   - `terraform.tfvars.example` - Template for bootstrap variables
   - `README.md` - Bootstrap usage instructions and prerequisites

2. **Resource Provisioning**: Use the `tfe` (Terraform Enterprise/HCP) provider to:
   - Create or reference HCP organization
   - Create HCP project for the landing zone
   - Create three workspaces (dev, staging, production) with appropriate settings
   - Configure workspace variables (environment, location, vm_size, etc.)
   - Set sensitive environment variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)
   - Configure workspace execution mode (remote) and Terraform version constraints

3. **Idempotency & Safety**: Design bootstrap to be:
   - **Idempotent**: Can be run multiple times without creating duplicates
   - **State-managed**: Uses local state file (gitignored) since HCP doesn't exist yet
   - **Conditional creation**: Check for existing resources before creating
   - **Output-driven**: Generates values consumed by main infrastructure

4. **Integration Workflow**:
   - Bootstrap runs once with local state before main infrastructure deployment
   - Main infrastructure environments reference bootstrap outputs (workspace names, project ID)
   - Backend configurations dynamically reference bootstrap-created workspaces
   - Team members clone repo, run bootstrap once, then work with remote state

## Relevant Files

### Existing Files to Move

**Terraform Infrastructure (Move to `infra/`):**

- `environments/dev/main.tf` - Dev environment root module → `infra/environments/dev/main.tf`
- `environments/dev/variables.tf` - Dev variables → `infra/environments/dev/variables.tf`
- `environments/dev/outputs.tf` - Dev outputs → `infra/environments/dev/outputs.tf`
- `environments/dev/backend.tf` - HCP backend config → `infra/environments/dev/backend.tf`
- `environments/dev/terraform.tfvars.example` - Dev var template → `infra/environments/dev/terraform.tfvars.example`
- `environments/staging/*` - All staging files → `infra/environments/staging/*`
- `environments/production/*` - All production files → `infra/environments/production/*`
- `modules/landing-zone/*` - Landing zone module → `infra/modules/landing-zone/*`
- `modules/networking/*` - Networking module → `infra/modules/networking/*`
- `modules/security/*` - Security module → `infra/modules/security/*`
- `modules/compute/*` - Compute module → `infra/modules/compute/*`
- `modules/governance/*` - Governance module → `infra/modules/governance/*`
- `versions.tf` - Provider versions → `infra/versions.tf`
- `terraform.tfvars.example` - Root variable template → `infra/terraform.tfvars.example`
- `README.md` - Current infrastructure docs → `infra/README.md`

**Existing Files to Update:**

- `.claude/CLAUDE.md` (lines 26-66) - Directory structure documentation needs updating
- `README.md` (root) - Will be replaced with new project-level README pointing to `infra/README.md`
- `.gitignore` - Already configured correctly for Terraform patterns

### New Files to Create

**Bootstrap Infrastructure (`infra/bootstrap/`):**

- `infra/bootstrap/main.tf` - HCP Terraform provider and resource definitions
  - `tfe_organization` data source (reference existing org)
  - `tfe_project` resource (create landing zone project)
  - `tfe_workspace` resources (dev, staging, production workspaces)
  - `tfe_variable` resources (environment variables, Azure credentials, workspace-specific vars)
  - `tfe_workspace_settings` (execution mode, Terraform version, working directory)
- `infra/bootstrap/variables.tf` - Bootstrap input variables
  - `hcp_token` - HCP Terraform API token (sensitive)
  - `organization_name` - HCP organization name
  - `project_name` - Project name (default: "azure-landing-zone")
  - `azure_subscription_id` - Azure subscription ID (sensitive)
  - `azure_tenant_id` - Azure AD tenant ID (sensitive)
  - `azure_client_id` - Service principal client ID (sensitive)
  - `azure_client_secret` - Service principal secret (sensitive)
  - `workspace_prefix` - Workspace naming prefix (default: "azure-landing-zone")
- `infra/bootstrap/outputs.tf` - Bootstrap outputs
  - `organization_name` - HCP organization name
  - `project_id` - Created project ID
  - `workspace_ids` - Map of environment to workspace ID
  - `workspace_names` - Map of environment to workspace name
- `infra/bootstrap/versions.tf` - Bootstrap provider versions
  - Terraform >= 1.9.0
  - `tfe` provider ~> 0.58.0 (HCP Terraform provider)
- `infra/bootstrap/terraform.tfvars.example` - Bootstrap variable template
- `infra/bootstrap/README.md` - Bootstrap usage documentation
- `infra/bootstrap/.gitignore` - Ignore local state (terraform.tfstate, .terraform/)

**Documentation Updates:**

- `README.md` (root) - New project-level overview
  - Points to `infra/README.md` for infrastructure docs
  - Documents orchestration framework (`.claude/`)
  - Explains bootstrap process
  - Quick start guide with bootstrap + infra workflow
- `infra/README.md` - Renamed from current `README.md`
  - Updated directory paths (add `infra/` prefix)
  - Updated setup instructions to include bootstrap step
  - Module source path updates in examples

## Implementation Phases

### Phase 1: Directory Reorganization Foundation

**Duration**: Single sequential execution
**Focus**: Create new structure and move files with git history preservation

**Tasks**:

1. Create `infra/` root directory
2. Move `environments/`, `modules/` directories using `git mv`
3. Move `versions.tf`, `terraform.tfvars.example` using `git mv`
4. Rename and move current `README.md` to `infra/README.md`
5. Update all module source paths in environment configurations
6. Update backend.tf working directories if needed
7. Validate Terraform configuration syntax after move

### Phase 2: HCP Bootstrap Implementation

**Duration**: Sequential implementation with validation
**Focus**: Create bootstrap automation module

**Tasks**:

1. Create `infra/bootstrap/` directory structure
2. Implement `versions.tf` with tfe provider configuration
3. Implement `variables.tf` with all bootstrap input variables
4. Implement `main.tf` with HCP resource provisioning:
   - Organization data source
   - Project resource
   - Workspace resources (dev, staging, production)
   - Variable resources (environment vars, Azure credentials)
   - Workspace settings (execution mode, Terraform version)
5. Implement `outputs.tf` with bootstrap outputs
6. Create `terraform.tfvars.example` template
7. Create bootstrap `.gitignore` for local state
8. Write comprehensive bootstrap `README.md` with usage instructions

### Phase 3: Documentation and Integration

**Duration**: Sequential validation and documentation
**Focus**: Update all documentation and validate end-to-end workflow

**Tasks**:

1. Create new root-level `README.md` with project overview
2. Update `infra/README.md` with new directory paths and bootstrap workflow
3. Update `.claude/CLAUDE.md` directory structure documentation
4. Create end-to-end setup guide (bootstrap → main infra workflow)
5. Update environment backend.tf files if needed to reference bootstrap outputs
6. Validate complete workflow: bootstrap → terraform init → terraform plan
7. Document troubleshooting steps for common bootstrap issues
8. Git commit all changes with comprehensive commit message

## Team Orchestration

You operate as the team lead and orchestrate the team to execute the plan. You're responsible for deploying the right team members with the right context to execute the plan.

**IMPORTANT**: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.

### Team Members

- **Pre-Flight Validator - Environment Check**
  - Name: preflight-env-validator
  - Role: Validate current environment state and prerequisites before reorganization
  - Agent Type: pre-flight
  - Resume: false

- **Builder - Directory Reorganization**
  - Name: builder-directory-reorg
  - Role: Move all IaC files into infra/ directory using git mv, update module paths
  - Agent Type: builder
  - Resume: false

- **Validator - Directory Structure**
  - Name: validator-directory-structure
  - Role: Verify all files moved correctly, module paths updated, no broken references
  - Agent Type: validator
  - Resume: false

- **Builder - HCP Bootstrap Module**
  - Name: builder-hcp-bootstrap
  - Role: Create bootstrap module with tfe provider resources for HCP provisioning
  - Agent Type: builder
  - Resume: false

- **Validator - Bootstrap Module**
  - Name: validator-bootstrap-module
  - Role: Verify bootstrap module syntax, validate tfe resources, check variable definitions
  - Agent Type: validator
  - Resume: false

- **Builder - Documentation Updates**
  - Name: builder-documentation
  - Role: Update README.md, infra/README.md, and .claude/CLAUDE.md with new structure
  - Agent Type: builder
  - Resume: false

- **Validator - Documentation**
  - Name: validator-documentation
  - Role: Verify all documentation updated, paths correct, instructions complete
  - Agent Type: validator
  - Resume: false

- **Test-Runner - Terraform Validation**
  - Name: test-runner-terraform
  - Role: Run terraform fmt, validate, and init checks on reorganized infrastructure
  - Agent Type: test-runner
  - Resume: false

- **Validator - Final Integration**
  - Name: validator-final-integration
  - Role: Run end-to-end validation of reorganization and bootstrap module
  - Agent Type: validator
  - Resume: false

- **Builder - Status Line Updates**
  - Name: builder-status-updates
  - Role: Update status line with progress throughout reorganization and bootstrap implementation
  - Agent Type: general-purpose
  - Resume: false

## Step by Step Tasks

**IMPORTANT**: Execute every step in order, top to bottom. Each task maps directly to a `TaskCreate` call. Before you start, run `TaskCreate` to create the initial task list that all team members can see and execute.

### 1. Pre-Flight Environment Validation

- **Task ID**: preflight-environment-check
- **Depends On**: none
- **Assigned To**: preflight-env-validator
- **Agent Type**: pre-flight
- **Parallel**: false
- Verify git repository is clean with no uncommitted changes (or document what needs committing)
- Check that all expected files exist: environments/, modules/, versions.tf, terraform.tfvars.example, README.md
- Verify Terraform is installed (>= 1.9.0)
- Verify git is installed and repository initialized
- Check current directory structure matches expectations
- Report current state and any blockers before reorganization

### 2. Create infra/ Directory Structure

- **Task ID**: create-infra-directory
- **Depends On**: preflight-environment-check
- **Assigned To**: builder-directory-reorg
- **Agent Type**: builder
- **Parallel**: false
- Create top-level `infra/` directory
- Create `infra/bootstrap/` directory for HCP bootstrap module
- Prepare directory structure for file moves

### 3. Move Infrastructure Files

- **Task ID**: move-infrastructure-files
- **Depends On**: create-infra-directory
- **Assigned To**: builder-directory-reorg
- **Agent Type**: builder
- **Parallel**: false
- Use `git mv` to move `environments/` to `infra/environments/` (preserves history)
- Use `git mv` to move `modules/` to `infra/modules/` (preserves history)
- Use `git mv` to move `versions.tf` to `infra/versions.tf`
- Use `git mv` to move `terraform.tfvars.example` to `infra/terraform.tfvars.example`
- Use `git mv` to move `README.md` to `infra/README.md`
- Verify all files moved successfully

### 4. Update Module Source Paths

- **Task ID**: update-module-paths
- **Depends On**: move-infrastructure-files
- **Assigned To**: builder-directory-reorg
- **Agent Type**: builder
- **Parallel**: false
- Update all module source references in `infra/environments/dev/main.tf` from `../../modules/X` to `../modules/X`
- Update all module source references in `infra/environments/staging/main.tf` from `../../modules/X` to `../modules/X`
- Update all module source references in `infra/environments/production/main.tf` from `../../modules/X` to `../modules/X`
- Verify no broken module references exist
- Run `terraform fmt -recursive` on infra/ directory

### 5. Update Backend Working Directories

- **Task ID**: update-backend-configs
- **Depends On**: update-module-paths
- **Assigned To**: builder-directory-reorg
- **Agent Type**: builder
- **Parallel**: false
- Review `infra/environments/*/backend.tf` files
- Add `working_directory` setting to HCP Terraform cloud block if needed (e.g., `working_directory = "infra/environments/dev"`)
- Ensure backend configurations point to correct workspace names
- Document any changes needed for HCP workspace settings

### 6. Validate Directory Reorganization

- **Task ID**: validate-directory-reorg
- **Depends On**: update-backend-configs
- **Assigned To**: validator-directory-structure
- **Agent Type**: validator
- **Parallel**: false
- Verify all files exist in `infra/` directory tree
- Check that `environments/`, `modules/`, `versions.tf`, `terraform.tfvars.example`, `README.md` no longer exist at root level
- Validate all module source paths updated correctly
- Run `terraform validate` on each environment (may fail due to backend, but syntax should be valid)
- Verify git history preserved for moved files using `git log --follow`
- Report any missing files or broken references

### 7. Create Bootstrap versions.tf

- **Task ID**: bootstrap-versions-file
- **Depends On**: validate-directory-reorg
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/versions.tf` with:
  - `required_version = ">= 1.9.0"`
  - `tfe` provider (hashicorp/tfe) ~> 0.58.0
  - Provider configuration block for tfe with token from environment variable
- Include header comment explaining bootstrap purpose (one-time HCP setup)

### 8. Create Bootstrap variables.tf

- **Task ID**: bootstrap-variables-file
- **Depends On**: bootstrap-versions-file
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/variables.tf` with input variables:
  - `organization_name` (string, HCP org name)
  - `project_name` (string, default "azure-landing-zone")
  - `workspace_prefix` (string, default "azure-landing-zone")
  - `azure_subscription_id` (string, sensitive)
  - `azure_tenant_id` (string, sensitive)
  - `azure_client_id` (string, sensitive)
  - `azure_client_secret` (string, sensitive)
  - `terraform_version` (string, default "~> 1.9.0")
- Add descriptions and validation blocks where appropriate
- Mark Azure credentials as sensitive

### 9. Create Bootstrap main.tf

- **Task ID**: bootstrap-main-file
- **Depends On**: bootstrap-variables-file
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/main.tf` with:
  - `data "tfe_organization"` - reference existing HCP organization
  - `resource "tfe_project"` - create landing zone project
  - `resource "tfe_workspace"` - create dev workspace with settings (execution_mode, terraform_version, working_directory)
  - `resource "tfe_workspace"` - create staging workspace with settings
  - `resource "tfe_workspace"` - create production workspace with settings
  - `resource "tfe_variable"` - create environment variable for each workspace (environment name)
  - `resource "tfe_variable"` - create Azure ARM_* environment variables for each workspace (sensitive)
  - Include locals for DRY configuration (common tags, workspace names)
- Add comprehensive comments explaining each resource
- Use for_each or count for creating multiple workspaces efficiently

### 10. Create Bootstrap outputs.tf

- **Task ID**: bootstrap-outputs-file
- **Depends On**: bootstrap-main-file
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/outputs.tf` with outputs:
  - `organization_name` - HCP organization name
  - `project_id` - Created project ID
  - `project_name` - Created project name
  - `workspace_ids` - Map of environment to workspace ID
  - `workspace_names` - Map of environment to workspace name
- Add descriptions for each output
- Mark sensitive outputs if needed

### 11. Create Bootstrap terraform.tfvars.example

- **Task ID**: bootstrap-tfvars-example
- **Depends On**: bootstrap-outputs-file
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/terraform.tfvars.example` with:
  - Example values for all bootstrap variables
  - Comments explaining how to obtain each value
  - Placeholder values for sensitive credentials (e.g., "your-subscription-id-here")
  - Reference to HCP token setup instructions

### 12. Create Bootstrap .gitignore

- **Task ID**: bootstrap-gitignore
- **Depends On**: bootstrap-tfvars-example
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/.gitignore` with patterns:
  - `*.tfstate` and `*.tfstate.backup` (local state files)
  - `.terraform/` (provider cache)
  - `*.tfvars` (sensitive values, except .example)
  - `.env` (environment variables)
- Add comment explaining bootstrap uses local state since HCP doesn't exist yet

### 13. Create Bootstrap README.md

- **Task ID**: bootstrap-readme
- **Depends On**: bootstrap-gitignore
- **Assigned To**: builder-hcp-bootstrap
- **Agent Type**: builder
- **Parallel**: false
- Create `infra/bootstrap/README.md` with sections:
  - **Purpose**: One-time HCP Terraform setup for landing zone
  - **Prerequisites**: HCP account, API token, Azure service principal
  - **Usage**: Step-by-step instructions for running bootstrap
  - **Variables**: Table of all input variables with descriptions
  - **Outputs**: Table of all outputs
  - **Post-Bootstrap**: Steps to use bootstrap outputs in main infrastructure
  - **Troubleshooting**: Common issues and solutions
- Include code examples for setup commands

### 14. Validate Bootstrap Module

- **Task ID**: validate-bootstrap-module
- **Depends On**: bootstrap-readme
- **Assigned To**: validator-bootstrap-module
- **Agent Type**: validator
- **Parallel**: false
- Verify all bootstrap files exist: versions.tf, variables.tf, main.tf, outputs.tf, .gitignore, README.md, terraform.tfvars.example
- Run `terraform fmt -check` on bootstrap directory
- Run `terraform validate` on bootstrap directory (will need TF_TOKEN set, but syntax should be valid)
- Check that all variables are used in main.tf
- Check that all outputs reference valid resources
- Verify README.md completeness and clarity
- Report any issues with bootstrap module

### 15. Create New Root README.md

- **Task ID**: create-root-readme
- **Depends On**: validate-bootstrap-module
- **Assigned To**: builder-documentation
- **Agent Type**: builder
- **Parallel**: false
- Create new `README.md` at project root with sections:
  - **Project Overview**: Azure Landing Zone with Terraform + HCP Terraform
  - **Repository Structure**: Document infra/, .claude/, specs/ organization
  - **Quick Start**: High-level workflow (bootstrap → infra deployment)
  - **Infrastructure**: Link to `infra/README.md` for detailed infrastructure docs
  - **Orchestration**: Link to `.claude/README.md` for framework docs
  - **Bootstrap Process**: Brief overview with link to `infra/bootstrap/README.md`
  - **Contributing**: Guidelines for contributing to infrastructure and docs
- Keep it concise as a project index pointing to detailed docs

### 16. Update infra/README.md

- **Task ID**: update-infra-readme
- **Depends On**: create-root-readme
- **Assigned To**: builder-documentation
- **Agent Type**: builder
- **Parallel**: false
- Update `infra/README.md` (renamed from original README.md):
  - Update all directory paths to include `infra/` prefix
  - Update "Directory Structure" section to reflect new organization
  - Add "Bootstrap Process" section referencing `infra/bootstrap/README.md`
  - Update setup instructions to include bootstrap step before main infra init
  - Update module source examples to show new relative paths
  - Verify all code blocks and commands reference correct paths

### 17. Update .claude/CLAUDE.md

- **Task ID**: update-claude-md
- **Depends On**: update-infra-readme
- **Assigned To**: builder-documentation
- **Agent Type**: builder
- **Parallel**: false
- Update `.claude/CLAUDE.md` directory structure (lines 26-66):
  - Add `infra/` as top-level container for all IaC
  - Update paths: `environments/` → `infra/environments/`, `modules/` → `infra/modules/`
  - Add `infra/bootstrap/` with description
  - Update relative paths in module examples
  - Add note about bootstrap process in setup workflow
- Update "Development Workflow" section (lines 250-289) to include bootstrap step
- Update any other references to directory structure or file paths

### 18. Validate Documentation Updates

- **Task ID**: validate-documentation
- **Depends On**: update-claude-md
- **Assigned To**: validator-documentation
- **Agent Type**: validator
- **Parallel**: false
- Verify new root `README.md` exists and contains all required sections
- Verify `infra/README.md` paths updated correctly (all references to environments/, modules/, etc. include infra/ prefix)
- Verify `.claude/CLAUDE.md` directory structure updated
- Check for broken links or incorrect paths in all documentation
- Verify documentation consistency across all three files
- Report any missing updates or path errors

### 19. Run Terraform Format and Validation

- **Task ID**: terraform-fmt-validate
- **Depends On**: validate-documentation
- **Assigned To**: test-runner-terraform
- **Agent Type**: test-runner
- **Parallel**: false
- Run `terraform fmt -recursive infra/` to format all Terraform code
- Run `terraform validate` on `infra/bootstrap/` (may need mock TF_TOKEN)
- Run `terraform validate` on `infra/environments/dev/` (will fail on backend, but syntax should validate)
- Run `terraform validate` on `infra/environments/staging/`
- Run `terraform validate` on `infra/environments/production/`
- Verify all modules have valid syntax
- Report any formatting or validation issues

### 20. Final Integration Validation

- **Task ID**: final-integration-validation
- **Depends On**: terraform-fmt-validate
- **Assigned To**: validator-final-integration
- **Agent Type**: validator
- **Parallel**: false
- Run comprehensive validation across all changes:
  - Verify infra/ directory structure complete and correct
  - Verify no Terraform files remain at root level (except orchestration files)
  - Verify bootstrap module is complete with all required files
  - Verify all documentation updated and consistent
  - Check git status for moved files (should show renames, not deletions + additions)
  - Verify .gitignore still covers all necessary patterns
  - Test that module paths are correct by checking `terraform init` readiness
- Generate comprehensive validation report with:
  - ✅ PASS items: All components successfully reorganized
  - ⚠️ WARNINGS: Any minor issues or recommendations
  - ❌ FAIL items: Any critical issues requiring remediation
- Provide overall assessment: READY FOR COMMIT or NEEDS REMEDIATION

## Acceptance Criteria

Infrastructure reorganization and HCP bootstrap are complete when ALL of the following criteria are met:

### Directory Structure Reorganization

1. **infra/ Directory**
   - [ ] `infra/` directory exists at project root
   - [ ] `infra/environments/` contains dev, staging, production subdirectories
   - [ ] `infra/modules/` contains landing-zone, networking, security, compute, governance subdirectories
   - [ ] `infra/versions.tf` exists with Terraform >= 1.9.0 constraint
   - [ ] `infra/terraform.tfvars.example` exists as variable template
   - [ ] `infra/README.md` exists with updated documentation
   - [ ] No Terraform IaC files remain at project root level

2. **Module Path Updates**
   - [ ] All environment main.tf files use correct relative module paths (../modules/X)
   - [ ] `terraform validate` passes for all environments (or fails only on missing backend, not syntax)
   - [ ] Git history preserved for all moved files (verifiable with `git log --follow`)

3. **Backend Configuration**
   - [ ] Backend.tf files updated with working_directory if needed
   - [ ] Workspace names correctly configured in all backend.tf files

### HCP Bootstrap Module

4. **Bootstrap Files**
   - [ ] `infra/bootstrap/versions.tf` exists with tfe provider ~> 0.58.0
   - [ ] `infra/bootstrap/variables.tf` exists with all required input variables (organization, project, Azure creds)
   - [ ] `infra/bootstrap/main.tf` exists with tfe resources (project, workspaces, variables)
   - [ ] `infra/bootstrap/outputs.tf` exists with organization, project, workspace outputs
   - [ ] `infra/bootstrap/terraform.tfvars.example` exists with example values
   - [ ] `infra/bootstrap/.gitignore` exists with local state patterns
   - [ ] `infra/bootstrap/README.md` exists with comprehensive usage instructions

5. **Bootstrap Resource Definitions**
   - [ ] tfe_organization data source references existing HCP org
   - [ ] tfe_project resource creates landing zone project
   - [ ] tfe_workspace resources create dev, staging, production workspaces
   - [ ] tfe_variable resources configure environment and Azure credentials for each workspace
   - [ ] Workspace settings include execution_mode, terraform_version, working_directory
   - [ ] All sensitive variables marked as sensitive = true

6. **Bootstrap Validation**
   - [ ] `terraform fmt -check` passes on bootstrap directory
   - [ ] `terraform validate` passes on bootstrap directory (with TF_TOKEN set)
   - [ ] All variables used in main.tf
   - [ ] All outputs reference valid resources

### Documentation

7. **Root README.md**
   - [ ] New `README.md` exists at project root
   - [ ] Contains project overview, repository structure, quick start
   - [ ] Links to `infra/README.md` for infrastructure docs
   - [ ] Links to `infra/bootstrap/README.md` for bootstrap process
   - [ ] Documents orchestration framework location (`.claude/`)

8. **Infrastructure Documentation**
   - [ ] `infra/README.md` updated with infra/ prefix in all paths
   - [ ] Directory structure diagram updated
   - [ ] Setup instructions include bootstrap step
   - [ ] Module source path examples updated

9. **Orchestration Documentation**
   - [ ] `.claude/CLAUDE.md` directory structure updated (lines 26-66)
   - [ ] Development workflow includes bootstrap step
   - [ ] All path references updated to include infra/ prefix

### Quality Checks

10. **Terraform Validation**
    - [ ] All .tf files formatted with `terraform fmt`
    - [ ] No syntax errors in any Terraform files
    - [ ] Module references resolve correctly
    - [ ] Provider configurations valid

11. **Git Status**
    - [ ] Git shows file moves (renames), not deletions + additions
    - [ ] All new files staged for commit
    - [ ] .gitignore patterns still cover necessary files

## Validation Commands

Execute these commands to validate the task is complete:

```bash
# Verify new directory structure
ls -la infra/
ls -la infra/environments/
ls -la infra/modules/
ls -la infra/bootstrap/

# Verify no IaC files remain at root
ls -la | grep -E "environments|modules|versions.tf|terraform.tfvars"
# Should return nothing

# Verify git history preserved for moved files
git log --follow --oneline infra/environments/dev/main.tf
git log --follow --oneline infra/modules/networking/main.tf

# Verify bootstrap module exists
ls -la infra/bootstrap/
# Should show: versions.tf, variables.tf, main.tf, outputs.tf, README.md, .gitignore, terraform.tfvars.example

# Format check all Terraform code
cd infra
terraform fmt -check -recursive
cd ..

# Validate bootstrap module syntax (requires TF_TOKEN)
cd infra/bootstrap
terraform init
terraform validate
cd ../..

# Validate environment configurations
cd infra/environments/dev
terraform validate
# May fail on backend, but syntax should be valid
cd ../../..

# Verify documentation updates
grep -n "infra/" README.md
# Should show multiple references to infra/ directory

grep -n "infra/" infra/README.md
# Should show updated paths

grep -n "infra/" .claude/CLAUDE.md
# Should show updated directory structure

# Count files in bootstrap
find infra/bootstrap -type f | wc -l
# Should be at least 7 files

# Verify module path updates
grep -r "source.*modules" infra/environments/
# Should show ../modules/X paths, not ../../modules/X

# Check git status
git status
# Should show renamed files, new bootstrap files, updated docs
```

## Notes

### Bootstrap Execution Flow

The bootstrap process is designed to run once before main infrastructure deployment:

1. **Clone Repository**: Team member clones the repo
2. **Configure Bootstrap**: Copy `infra/bootstrap/terraform.tfvars.example` to `terraform.tfvars` and fill in values
3. **Set HCP Token**: Export `TF_TOKEN_app_terraform_io` environment variable with HCP API token
4. **Run Bootstrap**:

   ```bash
   cd infra/bootstrap
   terraform init
   terraform plan
   terraform apply
   ```

5. **Capture Outputs**: Note the generated workspace names and project ID
6. **Configure Main Infrastructure**: Backend.tf files already reference correct workspace names
7. **Deploy Infrastructure**:

   ```bash
   cd ../environments/dev
   terraform init  # Now connects to HCP workspace created by bootstrap
   terraform plan
   terraform apply
   ```

### Bootstrap Idempotency

The bootstrap module should handle re-runs gracefully:

- Use `lifecycle { prevent_destroy = true }` on workspaces to prevent accidental deletion
- Use `ignore_changes` on workspace variables that may be updated manually in HCP UI
- Check for existing resources before creating (though tfe provider handles this well)

### State Management

- **Bootstrap**: Uses local state file (gitignored) since HCP doesn't exist yet at bootstrap time
- **Main Infrastructure**: Uses remote state in HCP workspaces created by bootstrap
- Team members only need to run bootstrap once per organization/project

### HCP Terraform Provider Authentication

The tfe provider requires authentication via:

- Environment variable: `TF_TOKEN_app_terraform_io`
- Or token in terraform block: `token = var.hcp_token`

Recommend environment variable approach for security.

### Azure Service Principal Setup

Before running bootstrap, users need:

1. Azure service principal with Contributor role on subscription
2. Service principal credentials: client_id, client_secret, tenant_id, subscription_id
3. These credentials will be stored as sensitive workspace variables in HCP

### Working Directory Configuration

After reorganization, HCP workspaces need `working_directory` setting:

- Dev workspace: `working_directory = "infra/environments/dev"`
- Staging workspace: `working_directory = "infra/environments/staging"`
- Production workspace: `working_directory = "infra/environments/production"`

This ensures HCP runs terraform commands in the correct directory.

### Module Source Path Changes

Before reorganization: `source = "../../modules/networking"`
After reorganization: `source = "../modules/networking"`

The change is from two levels up (project root → environments → dev) to one level up (infra → environments → dev).

### Git History Preservation

Using `git mv` instead of manual delete/add preserves file history:

```bash
git mv environments infra/environments
git mv modules infra/modules
```

This allows `git log --follow` to trace file history across the move.

### Documentation Structure After Reorganization

```text

README.md                    # Project overview, links to detailed docs
├── infra/
│   ├── README.md            # Infrastructure documentation (detailed)
│   └── bootstrap/
│       └── README.md        # Bootstrap process documentation
└── .claude/
    └── README.md            # Orchestration framework documentation
```

### Next Steps After This Plan

Once reorganization and bootstrap are complete:

1. Team members run bootstrap to provision HCP infrastructure
2. Update HCP workspace settings in UI if needed (execution mode, etc.)
3. Run `terraform init` in environment directories to connect to HCP remote state
4. Begin implementing actual infrastructure resources in modules
5. Deploy to dev environment for validation

### Dependencies

This plan creates foundational structure only:

- No actual Azure infrastructure resources created yet
- Modules still contain placeholder comments from foundation setup
- Bootstrap creates HCP structure but doesn't deploy Azure resources
- Actual resource implementation will be subsequent work

### Rollback Strategy

If issues arise during reorganization:

1. Use `git reset --hard` to undo uncommitted changes
2. Or use `git revert` to undo committed changes while preserving history
3. Bootstrap can be destroyed with `terraform destroy` in bootstrap directory
4. HCP workspaces can be manually deleted if bootstrap fails partially
