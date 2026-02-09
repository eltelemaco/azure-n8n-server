# Plan: Azure Landing Zone Foundation Setup

## Task Description
Initialize the foundational infrastructure for an Azure Landing Zone project using Terraform with HCP (HashiCorp Cloud Platform) state management. This includes setting up version control with git and creating the complete directory structure per the specifications in CLAUDE.md. The setup will establish the organizational structure for environments (dev, staging, production) and reusable Terraform modules (landing-zone, networking, security, compute, governance).

## Objective
Complete the foundation setup by initializing a git repository with proper configuration and creating the full directory structure that will support a modular Terraform-based Azure landing zone implementation following Azure Well-Architected Framework principles.

## Problem Statement
The project directory currently contains only the orchestration framework (.claude/) but lacks:
- Version control (git repository)
- Infrastructure code directory structure
- Environment-specific configuration directories
- Reusable Terraform module directories
- Supporting documentation and configuration templates

Without these foundational elements, infrastructure development cannot proceed according to the documented architecture patterns.

## Solution Approach
Implement a phased approach using specialized agent teams:

1. **Environment Validation Phase**: Verify all required tools (git, terraform) are available before starting
2. **Version Control Phase**: Initialize git repository with proper .gitignore for Terraform projects and initial commit
3. **Directory Structure Phase**: Create comprehensive directory hierarchy for environments and modules as specified in CLAUDE.md
4. **Documentation Phase**: Generate README.md with project overview, setup instructions, and usage guidelines
5. **Validation Phase**: Comprehensive verification that all components are correctly in place

Each phase uses dedicated builder and validator agent pairs to ensure quality and correctness.

## Relevant Files

### Existing Files to Reference
- `.claude/CLAUDE.md` (lines 26-99) - Defines the complete directory structure and conventions to implement
- `.claude/CLAUDE.md` (lines 619-620) - Specifies .gitignore patterns for Terraform projects
- `.claude/agents/team/builder.md` - Builder agent definition for implementation tasks
- `.claude/agents/team/validator.md` - Validator agent definition for verification tasks
- `.claude/agents/team/pre-flight.md` - Pre-flight agent definition for environment checks

### New Files to Create

#### Root Level Files
- `.gitignore` - Git ignore patterns for Terraform state files, .terraform directories, *.tfvars, .env files
- `README.md` - Project overview, architecture description, setup instructions, usage guide
- `terraform.tfvars.example` - Template for environment-specific variable values
- `versions.tf` - Terraform version constraints and required provider versions

#### Environment Directories
- `environments/dev/main.tf` - Dev environment root module
- `environments/dev/variables.tf` - Dev-specific variable declarations
- `environments/dev/outputs.tf` - Dev environment outputs
- `environments/dev/backend.tf` - HCP Terraform backend configuration for dev
- `environments/dev/terraform.tfvars.example` - Dev variable value template
- `environments/staging/` - Same structure as dev
- `environments/production/` - Same structure as dev

#### Module Directories
- `modules/landing-zone/main.tf` - Core landing zone module resources
- `modules/landing-zone/variables.tf` - Landing zone input variables
- `modules/landing-zone/outputs.tf` - Landing zone outputs
- `modules/landing-zone/README.md` - Landing zone module documentation
- `modules/networking/` - Virtual network, subnets, NSGs module (same file structure)
- `modules/security/` - Azure Policy, RBAC, Key Vault module (same file structure)
- `modules/compute/` - VM instances, scale sets module (same file structure)
- `modules/governance/` - Management groups, subscriptions module (same file structure)

## Implementation Phases

### Phase 1: Foundation
**Duration**: Single sequential execution
**Focus**: Environment validation and git initialization

1. Run comprehensive pre-flight checks to verify:
   - Git is installed and accessible
   - Terraform is installed (>= 1.9.0 per requirements)
   - Azure CLI is available (>= 2.60.0 per requirements)
   - Working directory is clean and ready for initialization

2. Initialize git repository with:
   - Proper .gitignore for Terraform projects
   - Initial commit with orchestration framework
   - Default branch configuration (main)

### Phase 2: Core Implementation
**Duration**: Parallel execution where possible
**Focus**: Directory structure creation and template files

1. Create complete directory hierarchy:
   - Three environment directories (dev, staging, production)
   - Five module directories (landing-zone, networking, security, compute, governance)
   - Each with proper file structure per CLAUDE.md specifications

2. Generate template files:
   - Starter main.tf, variables.tf, outputs.tf for each environment and module
   - README.md templates for each module
   - terraform.tfvars.example at root and in each environment

3. Create root-level configuration files:
   - versions.tf with Terraform >= 1.9.0 and Azure provider constraints
   - Root-level .gitignore with Terraform-specific patterns

### Phase 3: Integration & Polish
**Duration**: Sequential validation and documentation
**Focus**: Verification, documentation, and final validation

1. Validate all directory structures exist and are properly organized
2. Generate comprehensive README.md with:
   - Project overview and architecture description
   - Setup instructions (git, terraform, Azure CLI, HCP)
   - Directory structure explanation
   - Getting started guide
   - References to CLAUDE.md for detailed conventions

3. Run final comprehensive validation to ensure:
   - All directories and files exist
   - Git repository is properly initialized
   - All templates are in place
   - Documentation is complete and accurate

## Team Orchestration

You operate as the team lead and orchestrate the team to execute the plan. You're responsible for deploying the right team members with the right context to execute the plan.

**IMPORTANT**: You NEVER operate directly on the codebase. You use `Task` and `Task*` tools to deploy team members to do the building, validating, testing, deploying, and other tasks.

### Team Members

- **Pre-Flight Validator**
  - Name: preflight-env-check
  - Role: Validate that git, terraform, and Azure CLI are installed and environment is ready
  - Agent Type: pre-flight
  - Resume: false (single execution)

- **Git Builder**
  - Name: git-setup-builder
  - Role: Initialize git repository, create .gitignore, make initial commit
  - Agent Type: builder
  - Resume: false

- **Git Validator**
  - Name: git-setup-validator
  - Role: Verify git repository initialization, .gitignore content, and initial commit
  - Agent Type: validator
  - Resume: false

- **Structure Builder**
  - Name: directory-structure-builder
  - Role: Create all environment and module directories with template files
  - Agent Type: builder
  - Resume: false

- **Structure Validator**
  - Name: directory-structure-validator
  - Role: Verify all directories and template files exist and follow conventions
  - Agent Type: validator
  - Resume: false

- **Documentation Builder**
  - Name: readme-documentation-builder
  - Role: Generate comprehensive README.md with project overview and setup instructions
  - Agent Type: builder
  - Resume: false

- **Documentation Validator**
  - Name: readme-documentation-validator
  - Role: Verify README.md completeness, accuracy, and formatting
  - Agent Type: validator
  - Resume: false

- **Final Validator**
  - Name: final-validation-agent
  - Role: Run comprehensive final validation on entire foundation setup
  - Agent Type: validator
  - Resume: false

## Step by Step Tasks

**IMPORTANT**: Execute every step in order, top to bottom. Each task maps directly to a `TaskCreate` call. Before you start, run `TaskCreate` to create the initial task list that all team members can see and execute.

### 1. Pre-Flight Environment Check
- **Task ID**: preflight-env-check
- **Depends On**: none
- **Assigned To**: preflight-env-check
- **Agent Type**: pre-flight
- **Parallel**: false
- Run comprehensive pre-flight check covering:
  - Git installation and version check (git --version)
  - Terraform installation and version check (terraform --version >= 1.9.0)
  - Azure CLI installation and version check (az --version >= 2.60.0)
  - Python and uv availability for orchestration hooks
  - Current working directory status
- Report any blockers or warnings that would prevent successful foundation setup
- Provide remediation steps if any tools are missing or misconfigured

### 2. Initialize Git Repository
- **Task ID**: git-repo-init
- **Depends On**: preflight-env-check
- **Assigned To**: git-setup-builder
- **Agent Type**: builder
- **Parallel**: false
- Initialize git repository with `git init`
- Create comprehensive .gitignore file with Terraform-specific patterns:
  - `*.tfstate` and `*.tfstate.backup` (state files - must never commit)
  - `.terraform/` (provider plugins cache)
  - `*.tfvars` (sensitive variable values - except .example files)
  - `.env` (environment variables with credentials)
  - `*.pem`, `*.key` (SSH keys and certificates)
  - `**/.terraform.lock.hcl` should NOT be ignored (commit dependency locks)
- Stage all existing files (`.claude/`, `pyproject.toml`, new `.gitignore`)
- Create initial commit with message: "chore: initialize repository with agentic orchestration framework"
- Configure default branch name as `main`

### 3. Validate Git Setup
- **Task ID**: git-setup-validation
- **Depends On**: git-repo-init
- **Assigned To**: git-setup-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify git repository was initialized (`.git/` directory exists)
- Check `.gitignore` contains all required Terraform patterns
- Verify initial commit exists with correct message format
- Confirm default branch is `main`
- Run `git status` to verify clean working tree
- Report any issues with git configuration or .gitignore patterns

### 4. Create Directory Structure
- **Task ID**: directory-structure-creation
- **Depends On**: git-setup-validation
- **Assigned To**: directory-structure-builder
- **Agent Type**: builder
- **Parallel**: false
- Create environment directories with full file structure:
  - `environments/dev/` with main.tf, variables.tf, outputs.tf, backend.tf, terraform.tfvars.example
  - `environments/staging/` with same file structure
  - `environments/production/` with same file structure
- Create module directories with full file structure:
  - `modules/landing-zone/` with main.tf, variables.tf, outputs.tf, README.md
  - `modules/networking/` with main.tf, variables.tf, outputs.tf, README.md
  - `modules/security/` with main.tf, variables.tf, outputs.tf, README.md
  - `modules/compute/` with main.tf, variables.tf, outputs.tf, README.md
  - `modules/governance/` with main.tf, variables.tf, outputs.tf, README.md
- Create root-level files:
  - `versions.tf` with Terraform >= 1.9.0 constraint and Azure provider configuration
  - `terraform.tfvars.example` as template for variable values
- Add placeholder comments in all .tf files indicating purpose and next steps
- Follow naming conventions from CLAUDE.md (snake_case for variables, kebab-case for modules)

### 5. Validate Directory Structure
- **Task ID**: directory-structure-validation
- **Depends On**: directory-structure-creation
- **Assigned To**: directory-structure-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify all environment directories exist with correct file structure:
  - Check `environments/dev/`, `environments/staging/`, `environments/production/`
  - Verify each has main.tf, variables.tf, outputs.tf, backend.tf, terraform.tfvars.example
- Verify all module directories exist with correct file structure:
  - Check `modules/landing-zone/`, `modules/networking/`, `modules/security/`, `modules/compute/`, `modules/governance/`
  - Verify each has main.tf, variables.tf, outputs.tf, README.md
- Verify root-level files exist:
  - Check `versions.tf` contains Terraform version constraint >= 1.9.0
  - Check `terraform.tfvars.example` exists
- Run `find` commands to confirm directory structure matches CLAUDE.md specifications
- Report any missing directories or files

### 6. Generate Project Documentation
- **Task ID**: readme-documentation
- **Depends On**: directory-structure-validation
- **Assigned To**: readme-documentation-builder
- **Agent Type**: builder
- **Parallel**: false
- Create comprehensive README.md at project root with sections:
  - **Project Overview**: Azure Landing Zone with Terraform and HCP state management
  - **Architecture**: Hub-and-spoke network topology, modular design, HCP remote state
  - **Directory Structure**: Explanation of environments/ and modules/ organization
  - **Prerequisites**: Terraform >= 1.9.0, Azure CLI >= 2.60.0, Git, HCP Terraform account, Azure subscription
  - **Setup Instructions**:
    - Clone repository
    - Install prerequisites
    - Configure Azure CLI (`az login`)
    - Configure HCP Terraform (`terraform login`)
    - Initialize environment (`cd environments/dev && terraform init`)
  - **Getting Started**: Quick start commands for deploying to dev environment
  - **Module Documentation**: Brief description of each module's purpose
  - **Contributing**: Reference to CLAUDE.md for coding conventions and workflows
  - **References**: Links to Azure Well-Architected Framework, Terraform docs, HCP docs
- Use clear markdown formatting with code blocks for commands
- Include project status badge indicating "Foundation - Ready for Development"

### 7. Validate Documentation
- **Task ID**: documentation-validation
- **Depends On**: readme-documentation
- **Assigned To**: readme-documentation-validator
- **Agent Type**: validator
- **Parallel**: false
- Verify README.md exists at project root
- Check all required sections are present and complete:
  - Project Overview, Architecture, Directory Structure, Prerequisites, Setup Instructions, Getting Started
- Verify markdown syntax is valid
- Confirm code blocks use proper language identifiers (bash, hcl, etc.)
- Check that directory structure in README matches actual structure created
- Verify prerequisites match those specified in CLAUDE.md
- Report any missing sections or formatting issues

### 8. Final Comprehensive Validation
- **Task ID**: final-validation-all
- **Depends On**: documentation-validation
- **Assigned To**: final-validation-agent
- **Agent Type**: validator
- **Parallel**: false
- Run comprehensive validation across all foundation components:
  - Git repository initialized and clean
  - All environment directories exist with proper files
  - All module directories exist with proper files
  - Root-level configuration files exist
  - README.md complete and accurate
  - .gitignore properly configured for Terraform
- Execute validation commands:
  - `git status` - should show clean working tree (or staged changes ready for commit)
  - `find environments/ -type f` - verify all environment files exist
  - `find modules/ -type f` - verify all module files exist
  - `ls -la versions.tf terraform.tfvars.example README.md .gitignore` - verify root files exist
- Generate comprehensive validation report with:
  - ✅ PASS items: All components successfully created
  - ⚠️ WARNINGS: Any minor issues or recommendations
  - ❌ FAIL items: Any critical issues requiring remediation
- Provide overall assessment: READY FOR DEVELOPMENT or NEEDS REMEDIATION

## Acceptance Criteria

Foundation setup is complete when ALL of the following criteria are met:

1. **Git Repository**
   - [ ] Git repository initialized (`.git/` directory exists)
   - [ ] `.gitignore` file exists with Terraform-specific patterns (*.tfstate, .terraform/, *.tfvars, .env)
   - [ ] Initial commit created with orchestration framework
   - [ ] Default branch configured as `main`
   - [ ] Working tree is clean or has only documented changes

2. **Environment Directories**
   - [ ] `environments/dev/` exists with main.tf, variables.tf, outputs.tf, backend.tf, terraform.tfvars.example
   - [ ] `environments/staging/` exists with same file structure as dev
   - [ ] `environments/production/` exists with same file structure as dev
   - [ ] Each environment has placeholder comments indicating purpose

3. **Module Directories**
   - [ ] `modules/landing-zone/` exists with main.tf, variables.tf, outputs.tf, README.md
   - [ ] `modules/networking/` exists with complete file structure
   - [ ] `modules/security/` exists with complete file structure
   - [ ] `modules/compute/` exists with complete file structure
   - [ ] `modules/governance/` exists with complete file structure
   - [ ] Each module has placeholder README.md explaining its purpose

4. **Root-Level Files**
   - [ ] `versions.tf` exists with Terraform >= 1.9.0 constraint
   - [ ] `terraform.tfvars.example` exists as template
   - [ ] `README.md` exists with comprehensive project documentation

5. **Documentation**
   - [ ] README.md contains all required sections (Overview, Architecture, Setup, Getting Started)
   - [ ] Setup instructions reference CLAUDE.md for detailed workflows
   - [ ] Directory structure in README matches actual structure

6. **Validation**
   - [ ] All validation tasks passed (git, structure, documentation)
   - [ ] No critical issues reported by final validation
   - [ ] Project is ready for Terraform module development

## Validation Commands

Execute these commands to validate the task is complete:

```bash
# Verify git repository initialization
git status
git log --oneline -1
git branch --show-current

# Verify .gitignore has Terraform patterns
grep -E "\.tfstate|\.terraform|\.tfvars|\.env" .gitignore

# Verify environment directories structure
find environments/ -type f | sort

# Expected output should include:
# environments/dev/backend.tf
# environments/dev/main.tf
# environments/dev/outputs.tf
# environments/dev/terraform.tfvars.example
# environments/dev/variables.tf
# environments/staging/...
# environments/production/...

# Verify module directories structure
find modules/ -type f | sort

# Expected output should include:
# modules/compute/README.md
# modules/compute/main.tf
# modules/compute/outputs.tf
# modules/compute/variables.tf
# modules/governance/...
# modules/landing-zone/...
# modules/networking/...
# modules/security/...

# Verify root-level files
ls -la versions.tf terraform.tfvars.example README.md .gitignore

# Verify terraform version constraint in versions.tf
grep "required_version" versions.tf

# Count directories and files created
echo "Environment directories: $(find environments/ -mindepth 1 -maxdepth 1 -type d | wc -l)"
echo "Module directories: $(find modules/ -mindepth 1 -maxdepth 1 -type d | wc -l)"
echo "Total .tf files: $(find . -name '*.tf' -type f | wc -l)"
echo "Total README files: $(find . -name 'README.md' -type f | wc -l)"

# Expected counts:
# Environment directories: 3 (dev, staging, production)
# Module directories: 5 (landing-zone, networking, security, compute, governance)
# Total .tf files: At least 26 (3 envs × 4 files + 5 modules × 3 files + 1 versions.tf = 27)
# Total README files: At least 6 (1 root + 5 modules)
```

## Notes

### Dependencies
- This plan creates foundational structure only - no actual infrastructure code implementation
- Terraform modules will contain placeholder comments - actual resource definitions will be implemented in subsequent plans
- HCP Terraform workspace configuration in backend.tf will need organization name and workspace names (to be configured later)

### Azure Authentication
- Azure CLI must be installed and available, but authentication (`az login`) is not required for foundation setup
- Actual Azure operations will require authentication in later phases

### HCP Terraform Setup
- HCP Terraform account creation and workspace setup is documented but not automated
- Users will need to run `terraform login` manually and configure organization/workspace names in backend.tf

### `.gitignore` Critical Patterns
The .gitignore MUST include (per CLAUDE.md requirements):
- `*.tfstate` and `*.tfstate.backup` - State files contain sensitive data, never commit
- `.terraform/` - Provider plugins cache, regenerated on init
- `*.tfvars` - Contains sensitive values like credentials (but allow `*.tfvars.example`)
- `.env` - Environment variables with secrets
- `*.pem`, `*.key` - SSH keys and certificates

The .gitignore must NOT ignore:
- `.terraform.lock.hcl` - Dependency lock file (should be committed for reproducibility)

### Next Steps After Foundation
Once foundation is complete, subsequent development will include:
1. Implement networking module (VNets, subnets, NSGs)
2. Implement security module (Azure Policy, RBAC, Key Vault)
3. Implement compute module (VM instances)
4. Implement governance module (Management groups)
5. Implement landing-zone module (orchestrates other modules)
6. Configure HCP workspaces and remote state
7. Deploy to dev environment for validation

### File Count Validation
Expected minimum file counts after completion:
- Environment files: 15 (3 environments × 5 files each)
- Module files: 20 (5 modules × 4 files each)
- Root files: 4 (versions.tf, terraform.tfvars.example, README.md, .gitignore)
- Total: At least 39 files created (plus existing .claude/ framework files)
