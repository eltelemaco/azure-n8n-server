# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project implements an Azure landing zone using Terraform Infrastructure as Code (IaC) managed through HashiCorp Cloud Platform (HCP). The landing zone establishes foundational Azure infrastructure including networking, security, governance, and compute resources with an initial VM instance deployment following Azure Well-Architected Framework principles.

## Project Specifics

| Key              | Value                          |
|------------------|--------------------------------|
| **Name**         | azure-landing-zone-terraform   |
| **Language**     | HCL (HashiCorp Configuration Language) |
| **Framework**    | Terraform                      |
| **Stack**        | Azure, Terraform, HCP Terraform |
| **Build**        | `terraform plan`               |
| **Test**         | `terraform validate && terraform plan` |
| **Lint**         | `terraform fmt -check`         |
| **Pkg Manager**  | Terraform (modules via registry) |

## Architecture

This project follows a modular Terraform architecture with landing zone design patterns for Azure. Infrastructure is organized into reusable modules for networking, security, compute, and governance. State management is handled through HCP Terraform (formerly Terraform Cloud) for remote state storage, locking, and collaborative workflows.

### Directory Structure

```text
.
├── environments/                    # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf                 # Dev environment root module
│   │   ├── variables.tf            # Dev-specific variables
│   │   ├── terraform.tfvars        # Dev variable values
│   │   └── backend.tf              # HCP Terraform backend config
│   ├── staging/
│   └── production/
├── modules/                         # Reusable Terraform modules
│   ├── landing-zone/               # Core landing zone module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── networking/                 # Virtual network, subnets, NSGs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/                   # Azure Policy, RBAC, Key Vault
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                    # VM instances, scale sets
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── governance/                 # Management groups, subscriptions
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .terraform/                     # Terraform plugins (gitignored)
├── .terraform.lock.hcl             # Dependency lock file
├── .claude/                        # Orchestration framework
├── terraform.tfvars.example        # Example variable values
├── versions.tf                     # Provider version constraints
└── README.md                       # Project documentation
```

### Key Conventions

**Terraform Module Structure:**
- Each module has `main.tf`, `variables.tf`, `outputs.tf`, and `README.md`
- Use `terraform-docs` to auto-generate module documentation
- Version all module outputs to enable dependent modules

**Naming Conventions:**
- Resources: `<resource_type>-<environment>-<location>-<name>` (e.g., `vnet-dev-eastus-hub`)
- Variables: Use snake_case (e.g., `resource_group_name`)
- Modules: Use kebab-case (e.g., `landing-zone`, `networking`)
- Tags: All resources must include `environment`, `managed_by`, `project` tags

**State Management:**
- Remote state stored in HCP Terraform workspaces
- Each environment has a dedicated workspace
- State locking enabled automatically via HCP
- Sensitive outputs marked with `sensitive = true`

**Variable Management:**
- Define all variables in `variables.tf` with descriptions
- Use `terraform.tfvars` for environment-specific values (gitignored)
- Provide `terraform.tfvars.example` as template
- Store secrets in Azure Key Vault, reference via data sources

**Azure Landing Zone Patterns:**
- Hub-and-spoke network topology
- Azure Policy for governance and compliance
- Management groups for organizational hierarchy
- Azure Monitor and Log Analytics for observability
- Azure Bastion for secure VM access (no public IPs)

## Orchestration Protocol

This project uses the **agentic orchestration framework** with specialized agents for workflow management.

### Agent Definitions

#### Builder Agent

- **Purpose**: Implements infrastructure modules, writes Terraform code, creates configuration files
- **Model**: Claude Opus 4.5
- **Permissions**: Read, Write, Edit, Bash
- **When to use**: For all implementation tasks (new modules, resource definitions, variable configurations)

#### Validator Agent

- **Purpose**: Verifies Terraform code correctness, plan output, and compliance with Azure best practices
- **Model**: Claude Opus 4.5
- **Permissions**: Read, Bash (read-only, no Write/Edit)
- **When to use**: After builder completes work, to verify terraform validate passes and plan is safe

#### Test-Runner Agent

- **Purpose**: Runs terraform fmt, validate, plan, and compliance checks (tflint, checkov)
- **Model**: Claude Sonnet 4.5
- **Permissions**: Read, Bash (read-only, no Write/Edit)
- **When to use**: Before committing code, to ensure formatting and validation standards

#### Pre-Flight Agent

- **Purpose**: Validates environment readiness (Terraform installed, Azure CLI authenticated, HCP credentials configured)
- **Model**: Claude Haiku 4.5
- **Permissions**: Read, Bash (read-only, no Write/Edit)
- **When to use**: At session start or before terraform plan/apply operations

### Workflow Pattern

1. **Pre-Flight** → Validate environment (terraform version, az cli login, HCP token)
2. **Plan** → Create implementation plan (use `/plan` command)
3. **Build** → Implement via builder agent (use `/build` command)
4. **Validate** → Verify completion via validator agent (terraform validate, plan review)
5. **Test** → Run quality checks via test-runner agent (fmt, validate, tflint)
6. **Review** → Human review terraform plan output before apply
7. **Apply** → Execute terraform apply after approval
8. **Commit** → Git commit when infrastructure changes are applied

## Commands

This project includes custom slash commands:

- `/prime` - Load project context for new sessions
- `/plan` - Create implementation plans for infrastructure changes
- `/build` - Execute builder agent to implement Terraform modules
- `/question` - Answer questions about project structure and Azure architecture

## Hook System

The orchestration framework uses lifecycle hooks for:

- **PreToolUse**: Log tool calls before execution
- **PostToolUse**: Log results, trigger validators on Write/Edit (terraform fmt, terraform validate)
- **PostToolUseFailure**: Log errors for debugging
- **PermissionRequest**: Auto-allow safe operations (terraform fmt, terraform validate, az commands)
- **SessionStart/End**: Session lifecycle management
- **SubagentStart/Stop**: Agent lifecycle tracking

All hooks are Python scripts executed via `uv run --script` with PEP 723 inline dependencies.

## Guardrails

### Protected Paths

Do NOT modify or delete these paths without explicit permission:

**Terraform State:**
- `*.tfstate` - Local state files (should not exist with HCP backend)
- `*.tfstate.backup` - State backup files
- `.terraform/` - Provider plugins and modules cache
- `.terraform.lock.hcl` - Dependency lock file (commit this)

**Sensitive Files:**
- `terraform.tfvars` - Contains sensitive values (gitignored)
- `.env` - Environment variables with credentials
- `*.pem`, `*.key` - SSH keys and certificates

**Azure Resources:**
- Production environment configurations
- Existing resource groups with running workloads
- State storage accounts and containers

### Required Permissions

These operations require explicit user permission:

**Destructive Terraform Operations:**
- `terraform destroy` - Destroys all managed infrastructure
- `terraform apply` without reviewing plan first
- `terraform apply -auto-approve` - Bypasses approval
- Modifying production environment configurations
- Changing backend configuration (state migration)

**Azure Resource Changes:**
- Deleting resource groups
- Modifying network security rules in production
- Changing RBAC assignments
- Updating Azure Policy definitions
- VM deallocations or deletions

**State Management:**
- `terraform state mv` - Moving resources in state
- `terraform state rm` - Removing resources from state
- `terraform import` - Importing existing resources
- Workspace switching in production

### Validation Rules

**Pre-Commit Checks:**
1. Run `terraform fmt -recursive` to format all .tf files
2. Run `terraform validate` to check configuration syntax
3. Run `terraform plan` to preview changes
4. Review plan output for unexpected resource deletions or modifications
5. Verify no sensitive values are hardcoded in .tf files

**Code Quality:**
- All resources must have descriptive names
- All resources must include required tags (environment, managed_by, project)
- Use variables for all configurable values (no hardcoded values)
- Document all modules with README.md and variable descriptions
- Use data sources for existing resources instead of hardcoding IDs

**Security:**
- No public IP addresses without explicit justification
- Network security groups must follow least-privilege principle
- Secrets must be stored in Azure Key Vault
- Enable Azure Monitor for all resources
- Use managed identities instead of service principals where possible

## Development Workflow

### Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd azure-landing-zone-terraform

# Install Terraform
# Download from https://www.terraform.io/downloads
# Or use package manager:
# Windows: choco install terraform
# macOS: brew install terraform
# Linux: Follow official instructions

# Install Azure CLI
# Windows: winget install Microsoft.AzureCLI
# macOS: brew install azure-cli
# Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login
az account set --subscription <subscription-id>

# Configure HCP Terraform credentials
# Create API token at https://app.terraform.io/app/settings/tokens
# Set environment variable or use terraform login
terraform login

# Initialize Terraform
cd environments/dev
terraform init

# Verify setup
terraform version
az account show
terraform workspace show
```

### Daily Workflow

```bash
# Start session - load context
/prime

# Before making changes - validate environment
terraform version
az account show
terraform workspace show

# Navigate to environment
cd environments/dev

# Pull latest changes
git pull

# Initialize if needed
terraform init -upgrade

# Make infrastructure changes
# Edit .tf files in modules/ or environments/

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Review plan
terraform plan -out=tfplan

# Apply changes (after approval)
terraform apply tfplan

# Commit changes
git add <files>
git commit -m "feat(networking): add subnet for application tier"
git push
```

### Testing

```bash
# Format check (CI/CD)
terraform fmt -check -recursive

# Validate configuration
terraform validate

# Generate and review plan
terraform plan -out=tfplan

# Run tflint (if installed)
tflint --recursive

# Run Checkov security scanning (if installed)
checkov -d . --framework terraform

# Verify specific module
cd modules/networking
terraform init
terraform validate
```

### Linting and Formatting

```bash
# Format all Terraform files
terraform fmt -recursive

# Check formatting without changes
terraform fmt -check -recursive

# Validate configuration syntax
terraform validate

# Generate module documentation (if terraform-docs installed)
terraform-docs markdown table modules/networking > modules/networking/README.md
```

## Stack-Specific Guidelines

### Terraform Best Practices

**Module Design:**
- Keep modules focused and single-purpose
- Use input variables for all configurable aspects
- Output all resource IDs and important attributes
- Include examples/ directory in each module
- Version modules using git tags for production use

**Resource Organization:**
- Group related resources in the same .tf file
- Use descriptive file names (e.g., `network.tf`, `security.tf`, `compute.tf`)
- Separate data sources into `data.tf`
- Keep provider configuration in `providers.tf`
- Define versions in `versions.tf`

**Variable Validation:**
```hcl
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}
```

**Outputs:**
```hcl
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "admin_password" {
  description = "VM administrator password"
  value       = random_password.admin.result
  sensitive   = true
}
```

### Azure Landing Zone Conventions

**Network Topology:**
- Hub VNet: Central connectivity point (VPN, ExpressRoute, shared services)
- Spoke VNets: Workload-specific networks (peered to hub)
- Subnets: Segregate by tier (web, app, data, management)
- NSGs: Apply at subnet level with deny-by-default rules

**Resource Naming:**
```hcl
# Pattern: <resource-type>-<environment>-<location>-<name>
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${var.location}-landing-zone"
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.environment}-${var.location}-hub"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}
```

**Tagging Strategy:**
```hcl
locals {
  common_tags = {
    environment  = var.environment
    managed_by   = "terraform"
    project      = "azure-landing-zone"
    owner        = var.owner
    cost_center  = var.cost_center
    deployed_at  = timestamp()
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-landing-zone"
  location = var.location
  tags     = local.common_tags
}
```

### HCP Terraform Integration

**Backend Configuration:**
```hcl
# backend.tf
terraform {
  cloud {
    organization = "your-org-name"

    workspaces {
      name = "azure-landing-zone-dev"
    }
  }
}
```

**Workspace Strategy:**
- One workspace per environment (dev, staging, production)
- Use workspace-specific variable sets in HCP
- Enable remote execution for consistency
- Configure workspace VCS integration for automated runs

**Variable Sets in HCP:**
- Global variables: organization-wide settings
- Workspace variables: environment-specific values
- Sensitive variables: Azure credentials, API keys (marked sensitive)
- Environment variables: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID

### VM Instance Configuration

**Compute Module Pattern:**
```hcl
module "vm" {
  source = "../../modules/compute"

  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.subnet_ids["app"]

  vm_name             = "vm-${var.environment}-app-001"
  vm_size             = "Standard_D2s_v3"
  admin_username      = "azureadmin"

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  enable_boot_diagnostics = true
  enable_azure_monitor    = true

  tags = local.common_tags
}
```

**Security Best Practices:**
- Use Azure Key Vault for storing admin passwords
- Enable Azure Disk Encryption
- Configure managed identity for the VM
- Use Azure Bastion for SSH access (no public IPs)
- Enable Just-In-Time (JIT) VM access
- Configure Azure Monitor agent for logging

## Troubleshooting

### Common Issues

**Issue: Terraform initialization fails**
- Symptom: `terraform init` fails with backend configuration errors
- Solution:
  1. Verify HCP Terraform credentials: `terraform login`
  2. Check workspace name in `backend.tf` matches HCP workspace
  3. Ensure organization name is correct
  4. Run `rm -rf .terraform` and `terraform init` again

**Issue: Azure provider authentication fails**
- Symptom: `Error: Unable to list provider registration status`
- Solution:
  1. Verify Azure CLI login: `az account show`
  2. Set correct subscription: `az account set --subscription <id>`
  3. Check service principal credentials if using ARM_* environment variables
  4. Ensure appropriate Azure RBAC permissions (Contributor or Owner)

**Issue: Terraform plan shows unexpected resource replacements**
- Symptom: Plan shows resources will be destroyed and recreated
- Solution:
  1. Review what attribute changes triggered replacement
  2. Check if resource supports in-place updates
  3. Use `terraform state` commands to investigate
  4. Consider using `lifecycle { prevent_destroy = true }` for critical resources

**Issue: State lock acquisition failed**
- Symptom: `Error acquiring the state lock`
- Solution:
  1. In HCP Terraform, check if another run is in progress
  2. Cancel stale runs in HCP UI if needed
  3. For local state (not recommended): `terraform force-unlock <lock-id>`
  4. Wait for concurrent operations to complete

**Issue: Module source not found**
- Symptom: `Error: Failed to download module`
- Solution:
  1. Verify module source path is correct (relative paths for local modules)
  2. Run `terraform init -upgrade` to refresh module cache
  3. Check module version constraints in `source` attribute
  4. Ensure git credentials if using git-based modules

**Issue: Azure quota limits exceeded**
- Symptom: `QuotaExceeded` error during apply
- Solution:
  1. Check Azure subscription quotas: `az vm list-usage --location <location>`
  2. Request quota increase in Azure Portal
  3. Use smaller VM sizes or reduce instance count
  4. Deploy to different Azure regions with available capacity

## Environment Requirements

### Required

- **Terraform**: >= 1.9.0 (for HCP Terraform cloud block support)
- **Azure CLI**: >= 2.60.0 (for authentication)
- **Git**: >= 2.30.0 (for version control)
- **HCP Terraform Account**: Free tier or paid (for remote state management)
- **Azure Subscription**: With appropriate permissions (Contributor or Owner)

### Optional

- **tflint**: >= 0.50.0 (for Terraform linting)
- **Checkov**: >= 3.0.0 (for security scanning)
- **terraform-docs**: >= 0.17.0 (for module documentation)
- **pre-commit**: >= 3.0.0 (for git hooks with automated formatting)

### Environment Variables

**Azure Authentication (when using service principal):**
- `ARM_CLIENT_ID` - Azure service principal application ID
- `ARM_CLIENT_SECRET` - Azure service principal password
- `ARM_SUBSCRIPTION_ID` - Azure subscription ID
- `ARM_TENANT_ID` - Azure AD tenant ID

**HCP Terraform:**
- `TF_TOKEN_app_terraform_io` - HCP Terraform API token (alternative to terraform login)
- `TF_WORKSPACE` - Workspace name (for CLI-driven workflow)

**Optional:**
- `TF_LOG` - Enable Terraform debug logging (TRACE, DEBUG, INFO, WARN, ERROR)
- `TF_LOG_PATH` - Path to write Terraform logs

## Configuration Files

**Terraform:**
- `versions.tf` - Provider version constraints and required Terraform version
- `providers.tf` - Provider configuration (azurerm, random, etc.)
- `backend.tf` - HCP Terraform backend configuration
- `main.tf` - Root module resource definitions
- `variables.tf` - Input variable declarations
- `outputs.tf` - Output value definitions
- `terraform.tfvars` - Variable values (gitignored, sensitive)
- `terraform.tfvars.example` - Example variable values template
- `.terraform.lock.hcl` - Dependency lock file (commit to git)

**Orchestration:**
- `.claude/settings.local.json` - Orchestration hooks and permissions
- `.claude/CLAUDE.md` - Minimal project-level instructions
- `CLAUDE.md` - This file (comprehensive project guidance)

**Git:**
- `.gitignore` - Excludes .terraform/, *.tfstate, *.tfvars, .env

## Memory and Context

This project uses three-tier memory:

1. **Auto Memory**: Claude's automatic session memory at `~/.claude/projects/<project>/memory/`
2. **Agent Memory**: Agent-specific persistent memory in `.claude/agent-memory/`
3. **Project Memory**: Shared instructions in `CLAUDE.md` and `.claude/CLAUDE.md`

Use `/prime` at session start to load full project context including:
- Azure landing zone architecture patterns
- Terraform module structure and dependencies
- HCP workspace configuration
- Recent infrastructure changes and plan history

## Special Notes

**State Management Critical:**
- HCP Terraform manages state remotely - NEVER commit *.tfstate files
- State contains sensitive information (passwords, keys, connection strings)
- Use state locking to prevent concurrent modifications
- Back up HCP workspace regularly via API or export

**Azure Cost Management:**
- Use Azure Cost Management + Billing to monitor spending
- Tag all resources for cost allocation and tracking
- Use Azure Policy to enforce tagging standards
- Regularly review and deallocate unused resources
- Consider Azure Reserved Instances for production VMs

**Security Posture:**
- Follow Azure Security Benchmark recommendations
- Enable Azure Defender for all resource types
- Configure Azure Policy for compliance (CIS, NIST, PCI-DSS)
- Regularly review Azure Security Center recommendations
- Use Azure Private Link for PaaS services

**Compliance and Governance:**
- Azure Policy enforces organizational standards
- Management groups provide hierarchical governance
- Azure Blueprints for repeatable environment deployment
- Activity logs and Azure Monitor for audit trail
- Resource locks prevent accidental deletion (production)

**Disaster Recovery:**
- Document RTO (Recovery Time Objective) and RPO (Recovery Point Objective)
- Use Azure Site Recovery for VM replication
- Implement automated backup policies
- Test disaster recovery procedures regularly
- Maintain infrastructure-as-code for rapid rebuilding

---

## Generated by agentic-orchestration framework

This CLAUDE.md was generated using the `/scaffold` command from the agentic-orchestration repository. The orchestration framework provides lifecycle hooks, specialized agents, and workflow automation for Terraform infrastructure development.

**Framework repository**: https://github.com/anthropics/agentic-orchestration
**Documentation**: See `.claude/README.md` for orchestration system details
**Version**: 1.0.0
