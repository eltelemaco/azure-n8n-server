# Azure Landing Zone - Terraform

![Project Status: Foundation - Ready for Development](https://img.shields.io/badge/Status-Foundation%20%7C%20Ready%20for%20Development-blue)
![Terraform](https://img.shields.io/badge/Terraform-%3E%3D%201.9.0-purple)
![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4)
![HCP Terraform](https://img.shields.io/badge/State-HCP%20Terraform-7B42BC)
![License](https://img.shields.io/badge/License-Private-lightgrey)

A production-ready Azure Landing Zone built with Terraform and managed through HCP Terraform (formerly Terraform Cloud). This project establishes foundational Azure infrastructure including networking, security, governance, and compute resources following the [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) and [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) principles.

---

## Table of Contents

- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Getting Started](#getting-started)
- [Module Documentation](#module-documentation)
- [Environment Configuration](#environment-configuration)
- [Contributing](#contributing)
- [References](#references)

---

## Architecture

This landing zone implements a **hub-and-spoke network topology** with modular infrastructure components and remote state management via HCP Terraform.

### High-Level Overview

```
                          +---------------------------+
                          |     HCP Terraform         |
                          |  (Remote State & Runs)    |
                          +---------------------------+
                                      |
               +----------------------+----------------------+
               |                      |                      |
        +-----------+          +-----------+          +-----------+
        |    Dev    |          |  Staging  |          |Production |
        | Workspace |          | Workspace |          | Workspace |
        +-----------+          +-----------+          +-----------+
               |
               v
    +---------------------------------------------+
    |              Azure Subscription              |
    +---------------------------------------------+
    |                                             |
    |   Hub VNet (10.0.0.0/16)                    |
    |   +---------------------------------------+ |
    |   | Management Subnet  |  Bastion Subnet  | |
    |   | (10.0.1.0/24)      |  (10.0.2.0/26)   | |
    |   +---------------------------------------+ |
    |          |  VNet Peering  |                  |
    |   Spoke VNet (10.1.0.0/16)                  |
    |   +---------------------------------------+ |
    |   | Web Subnet   | App Subnet | Data Sub  | |
    |   | (10.1.1.0/24)|(10.1.2.0/24)|(10.1.3.0)| |
    |   +---------------------------------------+ |
    |                                             |
    |   +------------------+  +----------------+  |
    |   |  Azure Key Vault |  | Log Analytics  |  |
    |   +------------------+  +----------------+  |
    |                                             |
    |   +------------------+  +----------------+  |
    |   |  Linux VMs       |  | Azure Monitor  |  |
    |   |  (App Subnet)    |  | (Diagnostics)  |  |
    |   +------------------+  +----------------+  |
    |                                             |
    |   +------------------------------------------+
    |   |  Governance: Management Groups, Policies, |
    |   |  Budgets, Compliance (CIS/NIST/ASB)       |
    |   +------------------------------------------+
    +---------------------------------------------+
```

### Design Principles

- **Hub-and-spoke topology**: Centralized connectivity through a hub VNet with workload isolation in spoke VNets
- **Modular design**: Independent, reusable Terraform modules for each infrastructure domain
- **Remote state management**: HCP Terraform handles state storage, locking, and team collaboration
- **Security by default**: No public IPs on VMs, Azure Bastion for access, Key Vault for secrets, managed identities over service principals
- **Policy-driven governance**: Azure Policy enforces tagging, network restrictions, and compliance standards
- **Environment parity**: Consistent module structure across dev, staging, and production with environment-specific configurations

---

## Directory Structure

```
.
├── environments/                    # Environment-specific configurations
│   ├── dev/                         #   Development environment
│   │   ├── main.tf                  #     Root module (module composition)
│   │   ├── variables.tf             #     Variable declarations
│   │   ├── outputs.tf               #     Output definitions
│   │   ├── backend.tf               #     HCP Terraform backend config
│   │   └── terraform.tfvars.example #     Example variable values
│   ├── staging/                     #   Staging environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── backend.tf
│   └── production/                  #   Production environment
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── backend.tf
├── modules/                         # Reusable Terraform modules
│   ├── landing-zone/                #   Core infrastructure (resource group, logging)
│   ├── networking/                  #   Hub-and-spoke VNets, subnets, NSGs, Bastion
│   ├── security/                    #   Key Vault, managed identities, RBAC
│   ├── compute/                     #   Linux VMs, NICs, monitoring agents
│   └── governance/                  #   Management groups, policies, budgets
├── specs/                           # Project specifications
├── versions.tf                      # Provider version constraints
├── terraform.tfvars.example         # Root-level variable template
├── .gitignore                       # Git exclusions (state, secrets, cache)
└── CLAUDE.md                        # Development conventions and workflows
```

### Key Files

| File | Purpose |
|------|---------|
| `versions.tf` | Pins Terraform (>= 1.9.0) and provider versions (azurerm ~> 4.0, azuread ~> 3.0, random ~> 3.6, tls ~> 4.0) |
| `terraform.tfvars.example` | Template showing all configurable variables with documentation |
| `.gitignore` | Prevents committing state files, secrets, credentials, and plan files |
| `CLAUDE.md` | Comprehensive guide for coding conventions, naming standards, and workflows |

---

## Prerequisites

Before getting started, ensure you have the following installed and configured:

### Required

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [Terraform](https://www.terraform.io/downloads) | >= 1.9.0 | Infrastructure as Code engine (required for HCP `cloud` block) |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | >= 2.60.0 | Azure authentication and management |
| [Git](https://git-scm.com/downloads) | >= 2.30.0 | Version control |
| [HCP Terraform Account](https://app.terraform.io/signup/account) | Free or paid | Remote state management, locking, and collaboration |
| [Azure Subscription](https://azure.microsoft.com/en-us/free/) | Active | Target cloud environment (Contributor or Owner role required) |

### Optional

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [tflint](https://github.com/terraform-linters/tflint) | >= 0.50.0 | Terraform linting and best practice checks |
| [Checkov](https://www.checkov.io/) | >= 3.0.0 | Security and compliance scanning |
| [terraform-docs](https://terraform-docs.io/) | >= 0.17.0 | Auto-generate module documentation |
| [pre-commit](https://pre-commit.com/) | >= 3.0.0 | Git hooks for automated formatting |

### Verify Installation

```bash
# Check Terraform version
terraform version
# Expected: Terraform v1.9.x or later

# Check Azure CLI version
az version
# Expected: azure-cli 2.60.x or later

# Check Git version
git --version
# Expected: git version 2.30.x or later
```

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd azure-landing-zone-terraform
```

### 2. Install Prerequisites

**Windows:**

```bash
# Terraform
choco install terraform

# Azure CLI
winget install Microsoft.AzureCLI
```

**macOS:**

```bash
# Terraform
brew install terraform

# Azure CLI
brew install azure-cli
```

**Linux:**

```bash
# Terraform - follow official instructions at https://www.terraform.io/downloads

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 3. Authenticate with Azure

```bash
# Login to Azure (opens browser for interactive login)
az login

# Set the target subscription
az account set --subscription "<your-subscription-id>"

# Verify authentication
az account show --output table
```

### 4. Configure HCP Terraform

```bash
# Login to HCP Terraform (opens browser for token generation)
terraform login

# Alternatively, set the token as an environment variable:
# export TF_TOKEN_app_terraform_io="<your-api-token>"
```

> **Note:** Ensure your HCP Terraform organization and workspace names match the values in the environment's `backend.tf` file. Update `backend.tf` if needed before running `terraform init`.

### 5. Initialize the Development Environment

```bash
# Navigate to the dev environment
cd environments/dev

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# (Use your preferred editor)

# Initialize Terraform (downloads providers, configures backend)
terraform init
```

### 6. Verify Setup

```bash
# Validate configuration syntax
terraform validate

# Format check
terraform fmt -check

# Preview infrastructure changes
terraform plan
```

---

## Getting Started

Once setup is complete, use these commands to deploy the development environment:

```bash
# 1. Navigate to the dev environment
cd environments/dev

# 2. Review the plan (always review before applying)
terraform plan -out=tfplan

# 3. Apply the plan (requires confirmation)
terraform apply tfplan

# 4. View outputs after deployment
terraform output
```

### Common Operations

```bash
# Format all Terraform files recursively
terraform fmt -recursive

# Validate configuration
terraform validate

# Destroy all dev resources (use with caution)
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan

# Refresh state to match actual infrastructure
terraform plan -refresh-only

# List resources in state
terraform state list
```

### Environment Variables

When using a service principal for CI/CD or automated workflows, set these environment variables:

```bash
export ARM_CLIENT_ID="<service-principal-app-id>"
export ARM_CLIENT_SECRET="<service-principal-password>"
export ARM_SUBSCRIPTION_ID="<azure-subscription-id>"
export ARM_TENANT_ID="<azure-ad-tenant-id>"
```

---

## Module Documentation

The infrastructure is organized into five reusable modules, each responsible for a specific domain. Modules are composed together in environment-specific `main.tf` files.

### Landing Zone (`modules/landing-zone`)

The foundational module that all other modules depend on. Creates the core resource group, Log Analytics workspace, Azure Monitor action groups, and diagnostic settings for centralized logging and monitoring.

**Key resources:** Resource Group, Log Analytics Workspace, Monitor Action Groups, Diagnostic Settings

**Dependencies:** None (base module)

### Networking (`modules/networking`)

Implements a hub-and-spoke virtual network topology with network segmentation, security groups, and optional Azure Bastion for secure VM access.

**Key resources:** Hub VNet, Spoke VNet, VNet Peering, Subnets (management, web, app, data), Network Security Groups, Azure Bastion

**Dependencies:** Landing Zone (resource group)

```
Hub VNet (10.0.0.0/16)          Spoke VNet (10.1.0.0/16)
+---------------------+        +---------------------+
| Management Subnet   |        | Web Subnet          |
| (10.0.1.0/24)       |        | (10.1.1.0/24)       |
+---------------------+  Peer  +---------------------+
| Bastion Subnet      | <----> | App Subnet          |
| (10.0.2.0/26)       |        | (10.1.2.0/24)       |
+---------------------+        +---------------------+
                                | Data Subnet         |
                                | (10.1.3.0/24)       |
                                +---------------------+
```

### Security (`modules/security`)

Provides centralized secrets management, identity management, and Key Vault with RBAC authorization. Generates and stores VM admin passwords and creates managed identities for Azure resource access.

**Key resources:** Azure Key Vault, Managed Identities, RBAC Assignments, Key Vault Secrets, Diagnostic Settings

**Dependencies:** Landing Zone (Log Analytics workspace)

### Compute (`modules/compute`)

Deploys Linux virtual machines (Ubuntu 22.04 LTS) with secure configuration including private-only networking, managed identities, encrypted disks, and Azure Monitor integration.

**Key resources:** Linux VMs, Network Interfaces, OS Disks, Azure Monitor Agent Extension, Boot Diagnostics

**Dependencies:** Networking (subnet ID), Security (Key Vault, managed identity)

### Governance (`modules/governance`)

Establishes organizational governance through management group hierarchy, Azure Policy enforcement (tagging, network restrictions, compliance benchmarks), and cost management via budget alerts.

**Key resources:** Management Groups, Policy Definitions, Policy Assignments, Budget Alerts

**Dependencies:** None (operates at subscription/management group level)

### Module Dependency Graph

```
governance (independent)
    |
landing-zone (foundation)
    |
    +-- networking (requires: landing-zone)
    |
    +-- security (requires: landing-zone)
    |
    +-- compute (requires: networking, security)
```

---

## Environment Configuration

Each environment (dev, staging, production) has its own directory under `environments/` with dedicated Terraform configurations and an HCP Terraform workspace.

| Environment | Workspace | Purpose | Policy Enforcement |
|-------------|-----------|---------|-------------------|
| `dev` | `azure-landing-zone-dev` | Development and testing | Audit (permissive) |
| `staging` | `azure-landing-zone-staging` | Pre-production validation | Audit (permissive) |
| `production` | `azure-landing-zone-production` | Live workloads | Deny (strict) |

### Variable Customization

Copy the example variables file and customize it for your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Key variables include:

| Variable | Description | Example |
|----------|-------------|---------|
| `environment` | Environment name | `"dev"` |
| `location` | Azure region | `"eastus"` |
| `project_name` | Project identifier | `"azure-landing-zone"` |
| `vm_size` | VM SKU | `"Standard_D2s_v3"` |
| `enable_bastion` | Enable Azure Bastion | `true` |
| `enable_key_vault` | Enable Key Vault | `true` |
| `enable_monitoring` | Enable Azure Monitor | `true` |

See [`terraform.tfvars.example`](terraform.tfvars.example) for the complete list with descriptions.

---

## Contributing

This project uses coding conventions and workflows documented in [`CLAUDE.md`](CLAUDE.md). Please review it before contributing.

### Key Conventions

- **Resource naming**: `<resource_type>-<environment>-<location>-<name>` (e.g., `vnet-dev-eastus-hub`)
- **Variable naming**: `snake_case` (e.g., `resource_group_name`)
- **Module naming**: `kebab-case` (e.g., `landing-zone`)
- **Required tags**: All resources must include `environment`, `managed_by`, and `project` tags
- **No hardcoded values**: Use variables for all configurable settings
- **Module documentation**: Each module includes `main.tf`, `variables.tf`, `outputs.tf`, and `README.md`

### Workflow

1. Format code: `terraform fmt -recursive`
2. Validate syntax: `terraform validate`
3. Review plan: `terraform plan`
4. Apply only after human review of the plan output
5. Commit with descriptive messages: `git commit -m "feat(networking): add app tier subnet"`

### Pre-Commit Checklist

- [ ] All `.tf` files are formatted (`terraform fmt -check -recursive`)
- [ ] Configuration validates (`terraform validate`)
- [ ] Plan output reviewed for unexpected changes
- [ ] No sensitive values hardcoded in source files
- [ ] All resources have required tags
- [ ] Module README updated if inputs/outputs changed

---

## References

### Azure Documentation

- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/)
- [Azure Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure Policy Documentation](https://learn.microsoft.com/en-us/azure/governance/policy/)
- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Azure Monitor Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/)

### Terraform Documentation

- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform Azure Provider (azurerm)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Azure AD Provider (azuread)](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
- [Terraform Module Best Practices](https://developer.hashicorp.com/terraform/language/modules/develop)

### HCP Terraform

- [HCP Terraform Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [HCP Terraform Workspaces](https://developer.hashicorp.com/terraform/cloud-docs/workspaces)
- [HCP Terraform Variable Sets](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables/managing-variables)
- [HCP Terraform CLI-Driven Runs](https://developer.hashicorp.com/terraform/cloud-docs/run/cli)

### Security and Compliance

- [Azure Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/)
- [CIS Azure Foundations Benchmark](https://www.cisecurity.org/benchmark/azure)
- [Checkov - Terraform Security Scanner](https://www.checkov.io/)
- [tflint - Terraform Linter](https://github.com/terraform-linters/tflint)

---

## License

This project is proprietary. See your organization's license terms for usage and distribution.
