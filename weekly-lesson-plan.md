# AZ-104 + Terraform Associate: 8-Week Project-Based Study Guide

> **Role:** Senior Cloud Architect & DevOps Mentor | **Environment:** Personal Azure Account | **Time:** 5–6 hrs/week | **Constraint:** Cost-optimized, all cleanup via Terraform

***

## Study Guide Overview

This guide maps the five AZ-104 exam domains against progressively advanced Terraform concepts, organized into 8 modular weeks. Each week fits a 5–6 hour window and culminates in a real, deployable project. All infrastructure uses cost-optimized SKUs (B1s Linux VMs at ~$7.59/month on-demand, Free/Basic tiers) and is torn down with `terraform destroy` after verification.[1][2][3]

### Exam Domain Weights (AZ-104, Updated April 2025)[1]

| Domain | Weight |
|--------|--------|
| Manage Azure identities and governance | 20–25% |
| Implement and manage storage | 15–20% |
| Deploy and manage Azure compute resources | 20–25% |
| Configure and manage virtual networking | 15–20% |
| Monitor and maintain Azure resources | 10–15% |

### Terraform Associate 004 Key Facts[4]

- **Exam Code:** Terraform Associate (004) — launched January 8, 2026[4]
- **Duration:** 60 minutes, online proctored via Certiverse[4]
- **Terraform Version Tested:** 1.12[5]
- **Cost:** $70.50 USD[4]
- **8 Exam Domains** covering IaC concepts, workflow, configuration, state, modules, HCP Terraform, and best practices[6]

***

## Weekly Schedule at a Glance

| Week | AZ-104 Domain | Terraform Focus | Mini-Project |
|------|---------------|-----------------|--------------|
| 1 | Identities & Governance (Part 1) | Providers, Variables | RBAC & Entra ID via Terraform |
| 2 | Identities & Governance (Part 2) | Outputs, Local Values | Azure Policy & Management Groups |
| 3 | Storage | Local State → Remote Backend | Secure Storage Account Setup |
| 4 | Compute (Part 1) | Workspaces, Provisioners | B1s Linux VM with Cloud-Init |
| 5 | Compute (Part 2) | Advanced Modules | VM Scale Set with Reusable Module |
| 6 | Networking | `for_each`, `count`, Dynamic Blocks | Hub-and-Spoke VNet with Peering |
| 7 | Networking (Advanced) | Conditional Logic, Functions | Load Balancer + NSG Factory |
| 8 | Monitor & Backup | `terraform_remote_state`, Capstone | Full-Stack Monitoring + Cleanup |

***

## Week 1 — Identities & Governance: Users, Groups, and RBAC

### AZ-104 Domain Focus
**Manage Azure Identities and Governance (Part 1):** Microsoft Entra ID (formerly Azure AD) user/group management, role-based access control (RBAC), and Azure subscription structure. This domain carries 20–25% exam weight — the heaviest focus of the guide.[7][1]

### Terraform Concept Focus
**Providers, Variables, and `terraform.tfvars`** — Configuring the `azurerm` provider with authentication, declaring input variables with types and defaults, and separating configuration from values using `.tfvars` files.[8][9]

📚 **Deep-Dive Links**
- [AZ-104: Manage Identities and Governance — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/)[7]
- [Define Input Variables — HashiCorp Tutorial](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-variables)[9]
- [AzureRM Provider Docs — Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)[10]

***

### Mini-Project: Governed Subscription Foundation

**Scenario:** Build the identity foundation for a fictional company. Create Entra ID users and groups, assign custom RBAC roles at the resource group scope, and enforce a tagging requirement via Azure Policy — all in Terraform.

**Estimated Time:** 5 hours (1 hr reading + 3 hrs build + 1 hr verify/cleanup)

#### Step-by-Step Task List (HCL)

**`providers.tf`**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
```

**`variables.tf`**
```hcl
variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "Environment tag value"
  default     = "learning"
}

variable "project_name" {
  type        = string
  description = "Short project identifier used in resource names"
  default     = "az104-w1"
}
```

**`terraform.tfvars`**
```hcl
location     = "eastus"
environment  = "learning"
project_name = "az104-w1"
```

**`main.tf`**
```hcl
# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Entra ID Group
resource "azuread_group" "dev_team" {
  display_name     = "grp-${var.project_name}-devs"
  security_enabled = true
}

# Entra ID User (practice account — do NOT use production credentials)
resource "azuread_user" "dev_user" {
  user_principal_name = "devuser1@<YOUR_TENANT>.onmicrosoft.com"
  display_name        = "Dev User 1"
  password            = "P@ssword1Temp!" # rotate immediately
}

# Add user to group
resource "azuread_group_member" "dev_member" {
  group_object_id  = azuread_group.dev_team.object_id
  member_object_id = azuread_user.dev_user.object_id
}

# RBAC: Assign Contributor to the dev group on the RG
resource "azurerm_role_assignment" "dev_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.dev_team.object_id
}

# Azure Policy: Require 'Environment' tag on all resources
resource "azurerm_policy_assignment" "require_env_tag" {
  name                 = "require-env-tag"
  scope                = azurerm_resource_group.rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  display_name         = "Require Environment tag"
}
```

#### Verification Steps

```bash
# 1. Confirm resource group exists with correct tags
az group show --name "rg-az104-w1-learning" \
  --query "{name:name, tags:tags}" -o table

# 2. List RBAC assignments on the resource group
az role assignment list \
  --scope $(az group show -n rg-az104-w1-learning --query id -o tsv) \
  --output table

# 3. Verify the Entra ID group was created
az ad group list --filter "displayName eq 'grp-az104-w1-devs'" -o table

# 4. Confirm user is a group member
az ad group member list --group "grp-az104-w1-devs" -o table

# 5. Check policy assignment
az policy assignment list --scope \
  $(az group show -n rg-az104-w1-learning --query id -o tsv) -o table
```

#### ⚠️ Cost Warning
- **Resource Groups, Entra ID users/groups, RBAC, and Policy assignments are FREE.**
- No compute resources are deployed this week — zero cost impact.
- Verify no accidental resources are deployed via `terraform state list`.

#### 🧹 Clean-Up Command
```bash
terraform destroy -auto-approve
# Confirm residual state is empty:
terraform state list
```

***

## Week 2 — Identities & Governance: Management Groups and Blueprints

### AZ-104 Domain Focus
**Manage Azure Identities and Governance (Part 2):** Azure Management Groups hierarchy, subscription management, Azure Policy Initiatives (policy sets), and resource locks. Understanding the management group → subscription → resource group → resource hierarchy is a frequent exam topic.[11][12]

### Terraform Concept Focus
**Outputs and Local Values** — Using `output` blocks to expose resource attributes for cross-module consumption, and `locals` to define computed values and avoid repetition within a configuration.[8][9]

📚 **Deep-Dive Links**
- [AZ-104: Manage Identities and Governance — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/)[7]
- [Query Data with Output Values — HashiCorp Tutorial](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-outputs)[8]
- [AZ-104 Exam Readiness Zone: Governance (Ep. 1 of 5) — Microsoft Learn](https://learn.microsoft.com/en-us/shows/exam-readiness-zone/preparing-for-az-104-manage-azure-identities-and-governance-1-of-5)[13]

***

### Mini-Project: Policy Initiative + Resource Lock Automation

**Scenario:** Build a multi-resource-group environment with a Policy Initiative enforcing two rules (require tags + restrict VM SKUs), and apply a resource lock to a "production" resource group to prevent accidental deletion.

**Estimated Time:** 5 hours (1 hr reading + 3.5 hrs build + 0.5 hr verify/cleanup)

#### Step-by-Step Task List (HCL)

**`locals.tf`**
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "az104-study"
  }
  rg_name_dev  = "rg-${var.project_name}-dev"
  rg_name_prod = "rg-${var.project_name}-prod"
}
```

**`main.tf` (key excerpts)**
```hcl
resource "azurerm_resource_group" "dev" {
  name     = local.rg_name_dev
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "prod" {
  name     = local.rg_name_prod
  location = var.location
  tags     = local.common_tags
}

# Policy definition: restrict VM SKUs to B-series only
resource "azurerm_policy_definition" "allowed_sku" {
  name         = "allowed-vm-skus-b-series"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allow B-Series VMs Only"

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Compute/virtualMachines" },
        { field = "Microsoft.Compute/virtualMachines/sku.name", notIn = ["Standard_B1s", "Standard_B2s", "Standard_B1ms"] }
      ]
    }
    then = { effect = "Deny" }
  })
}

# Resource Lock on prod RG
resource "azurerm_management_lock" "prod_lock" {
  name       = "lock-${local.rg_name_prod}"
  scope      = azurerm_resource_group.prod.id
  lock_level = "CanNotDelete"
  notes      = "Protected production resource group"
}
```

**`outputs.tf`**
```hcl
output "dev_rg_id" {
  description = "Resource ID of the dev resource group"
  value       = azurerm_resource_group.dev.id
}

output "prod_rg_id" {
  description = "Resource ID of the prod resource group"
  value       = azurerm_resource_group.prod.id
}

output "policy_definition_id" {
  description = "Custom policy definition resource ID"
  value       = azurerm_policy_definition.allowed_sku.id
}
```

#### Verification Steps

```bash
# Verify both resource groups
az group list --query "[?contains(name,'az104-w2')]" -o table

# Check resource lock on prod
az lock list --resource-group "rg-az104-w2-prod" -o table

# Test the lock (should FAIL — this is expected)
az group delete --name "rg-az104-w2-prod" --yes 2>&1 | grep -i "locked\|error"

# View Terraform outputs
terraform output
```

#### ⚠️ Cost Warning
- All resources (RGs, Policy definitions, Locks) are **FREE**.
- **Critical:** The resource lock will cause `terraform destroy` to fail unless removed first.

#### 🧹 Clean-Up Command
```bash
# IMPORTANT: Remove the lock before destroy
terraform state rm azurerm_management_lock.prod_lock
az lock delete --name "lock-rg-az104-w2-prod" \
  --resource-group "rg-az104-w2-prod"

# Now destroy all remaining resources
terraform destroy -auto-approve
```

***

## Week 3 — Storage: Accounts, Blobs, and Files

### AZ-104 Domain Focus
**Implement and Manage Storage (15–20%):** Azure Storage Account configuration (replication, tiers, access keys, SAS tokens), Blob Storage lifecycle management, Azure Files shares, and storage security (private endpoints, firewalls).[14]

### Terraform Concept Focus
**Local State → Remote Backend (Azure Blob Storage)** — Understanding why local state is unsuitable for shared environments, bootstrapping a remote backend, migrating state, and enabling state locking.[15][16][17]

📚 **Deep-Dive Links**
- [AZ-104: Implement and Manage Storage — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-storage/)[14]
- [Remote Backend with Azure Blob Storage — Terraform Workshop](https://terraform-workshop.com/managing-terraform-state/hands-on-exercise/)[16]
- [Terraform Backend Configuration — GitHub Example](https://github.com/terraform-azure-iac/terraform-azure-backend)[17]

***

### Mini-Project: Secure Storage Account with Remote State Backend

**Scenario:** Two-phase project. Phase 1: Bootstrap a remote state backend using Azure CLI. Phase 2: Deploy a production-ready storage account (LRS, Hot tier, private blob access) with Terraform using that remote backend.

**Estimated Time:** 5.5 hours (1.5 hrs reading + 3 hrs build + 1 hr verify/cleanup)

#### Phase 1 — Bootstrap Backend (Azure CLI, not Terraform)

```bash
# Variables
BACKEND_RG="rg-tfstate-backend"
BACKEND_SA="tfstateXXXXXX"   # Replace XXXXXX with random suffix
BACKEND_CONTAINER="tfstate"
LOCATION="eastus"

# Create backend resources
az group create --name $BACKEND_RG --location $LOCATION
az storage account create \
  --name $BACKEND_SA \
  --resource-group $BACKEND_RG \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2

az storage container create \
  --name $BACKEND_CONTAINER \
  --account-name $BACKEND_SA

echo "Backend ready: $BACKEND_SA / $BACKEND_CONTAINER"
```

#### Phase 2 — Project Terraform Config

**`backend.tf`**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-backend"
    storage_account_name = "tfstateXXXXXX"   # your actual name
    container_name       = "tfstate"
    key                  = "week3/storage.tfstate"
  }
}
```

**`main.tf`**
```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-storage"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "main" {
  name                     = "st${var.project_name}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  # Disable public blob access
  allow_nested_items_to_be_public = false

  # Enable blob soft delete (30 days)
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.common_tags
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Blob container
resource "azurerm_storage_container" "data" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Azure File Share (Free tier: first 5GB free in some regions)
resource "azurerm_storage_share" "files" {
  name                 = "shared-config"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 1 # 1 GiB minimum
}

# Lifecycle management policy
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "move-to-cool-after-30-days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
      prefix_match = ["app-data/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than       = 365
      }
    }
  }
}
```

#### Verification Steps

```bash
# Confirm remote state was stored
az storage blob list \
  --container-name tfstate \
  --account-name $BACKEND_SA \
  --output table

# Verify storage account properties
az storage account show \
  --name <your-storage-account-name> \
  --query "{sku:sku, kind:kind, minTls:minimumTlsVersion, publicAccess:allowBlobPublicAccess}" \
  -o table

# List containers in storage account
az storage container list \
  --account-name <your-storage-account-name> \
  --output table

# Test state locking (run in a second terminal during apply)
terraform plan  # Should show "Acquiring state lock"
```

#### ⚠️ Cost Warning
- **Standard LRS Storage Account**: ~$0.018/GB/month for Hot tier — minimal for test blobs.[18]
- **Azure File Share**: First 100GB is ~$0.06/GB/month — keep quota at 1 GiB.
- **Backend storage account itself incurs a small cost** (~$0.002/day for the state blob). Delete after the course if not reusing.

#### 🧹 Clean-Up Command
```bash
# Destroy project resources (NOT the backend — you'll reuse it)
terraform destroy -auto-approve

# Optional: Manually delete backend if done with course
az group delete --name rg-tfstate-backend --yes --no-wait
```

***

## Week 4 — Compute: Virtual Machines and Availability

### AZ-104 Domain Focus
**Deploy and Manage Azure Compute Resources (Part 1, 20–25%):** Azure Virtual Machines (deployment, sizing, availability sets, availability zones), VM extensions, Azure Disk management, and VM backup. Focus on B-series VM sizing and cost optimization.[19]

### Terraform Concept Focus
**Workspaces and Provisioners** — Using `terraform workspace` to maintain separate `dev` and `prod` state within the same config, and `remote-exec`/`file` provisioners for basic post-deployment configuration (understand the AZ-104 exam prefers Azure-native tools; provisioners are Terraform exam territory).[20][5]

📚 **Deep-Dive Links**
- [AZ-104: Deploy and Manage Compute Resources — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-compute-resources/)[19]
- [Terraform Workspaces and Remote State in Azure — Tutorial](https://danielwertheim.se/terraform-workspaces-and-remote-state-in-azure/)[20]
- [HashiCorp: Terraform Workspace Docs](https://developer.hashicorp.com/terraform/language/state/workspaces)

***

### Mini-Project: Cost-Optimized Linux VM with Dev/Prod Workspaces

**Scenario:** Deploy a B1s Ubuntu VM with SSH key auth into a dev workspace (no public IP) and a prod workspace (with a locked-down NSG). Use `terraform.workspace` to toggle configuration between environments.

**Estimated Time:** 6 hours (1 hr reading + 4 hrs build + 1 hr verify/cleanup)

#### Step-by-Step Task List (HCL)

**`variables.tf`**
```hcl
variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
```

**`main.tf`**
```hcl
locals {
  is_prod      = terraform.workspace == "prod"
  vm_size      = local.is_prod ? "Standard_B2s" : "Standard_B1s"
  env_suffix   = terraform.workspace
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-compute-${local.env_suffix}"
  location = var.location
  tags     = { Environment = local.env_suffix, ManagedBy = "Terraform" }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-compute-${local.env_suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "main" {
  name                 = "snet-main"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-vm-${local.env_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.is_prod ? "10.0.0.0/8" : "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vm_pip" {
  count               = local.is_prod ? 0 : 1  # No public IP in prod
  name                = "pip-vm-${local.env_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-vm-${local.env_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.is_prod ? null : (
      length(azurerm_public_ip.vm_pip) > 0 ? azurerm_public_ip.vm_pip[0].id : null
    )
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${local.env_suffix}-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = local.vm_size   # B1s in dev, B2s in prod
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  # Cost optimization: disable diagnostics by default
  patch_mode = "AutomaticByPlatform"

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Cheapest option
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = { Environment = local.env_suffix, ManagedBy = "Terraform" }
}
```

#### Workspace Commands

```bash
# Create and switch to dev workspace
terraform workspace new dev
terraform workspace select dev
terraform apply -auto-approve

# Switch to prod, uses same config with different logic
terraform workspace new prod
terraform workspace select prod
terraform apply -auto-approve
```

#### Verification Steps

```bash
# List active workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Confirm VM size per workspace
az vm list \
  --query "[].{Name:name, Size:hardwareProfile.vmSize, RG:resourceGroup}" \
  -o table

# Check dev workspace has public IP, prod does not
az network public-ip list \
  --query "[?contains(name,'pip-vm')]" \
  -o table

# Connect to dev VM
ssh -i ~/.ssh/id_rsa azureadmin@$(terraform output -raw public_ip)
```

#### ⚠️ Cost Warning
- **Standard_B1s (dev)**: ~$7.59/month — **STOP THE VM when not studying**: `az vm deallocate -g rg-compute-dev -n vm-dev-01`[3]
- **Standard_B2s (prod)**: ~$30/month — only deploy briefly for verification, then destroy immediately.
- **Standard_LRS OS disk**: ~$1.20/month for 30 GB.
- **Total max weekly cost**: <$2 if you deallocate VMs after each session.

#### 🧹 Clean-Up Command
```bash
# Destroy prod first
terraform workspace select prod
terraform destroy -auto-approve

# Then dev
terraform workspace select dev
terraform destroy -auto-approve

# Clean up workspaces
terraform workspace select default
terraform workspace delete dev
terraform workspace delete prod
```

***

## Week 5 — Compute: Containers, Scale Sets, and App Service

### AZ-104 Domain Focus
**Deploy and Manage Azure Compute Resources (Part 2):** Azure Kubernetes Service (AKS) basics, Azure Container Instances (ACI), VM Scale Sets, Azure App Service plans, and deployment slots. The exam tests your ability to choose the right compute service for a given workload.[19]

### Terraform Concept Focus
**Advanced Modules with Inputs/Outputs** — Building a reusable child module for a VM scale set, using module input variables and output values to compose infrastructure, and understanding the module registry pattern.[21][5]

📚 **Deep-Dive Links**
- [AZ-104: Deploy and Manage Compute Resources — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-compute-resources/)[19]
- [Create Azure VM Scale Set Using Terraform — Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/terraform/create-vm-scaleset-network-disks-hcl)[22]
- [Terraform Module Documentation — HashiCorp](https://developer.hashicorp.com/terraform/language/modules)

***

### Mini-Project: Reusable VM Scale Set Module

**Scenario:** Author a local Terraform module (`modules/vmss`) that encapsulates a VM Scale Set with autoscale profile. Call the module twice from the root to create a "web tier" and an "api tier" Scale Set — demonstrating module reusability.

**Estimated Time:** 6 hours (1 hr reading + 4.5 hrs build + 0.5 hr verify/cleanup)

#### Step-by-Step Task List (HCL)

**Directory structure:**
```
week5/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
└── modules/
    └── vmss/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**`modules/vmss/variables.tf`**
```hcl
variable "name_prefix"        { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "subnet_id"           { type = string }
variable "vm_sku"              { type = string; default = "Standard_B1s" }
variable "instance_count"      { type = number; default = 1 }
variable "admin_username"      { type = string }
variable "ssh_public_key"      { type = string }
variable "tags"                { type = map(string); default = {} }
```

**`modules/vmss/main.tf`**
```hcl
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.name_prefix}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_sku
  instances           = var.instance_count

  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.name_prefix}-nic"
    primary = true
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  tags = var.tags
}
```

**`modules/vmss/outputs.tf`**
```hcl
output "vmss_id"   { value = azurerm_linux_virtual_machine_scale_set.vmss.id }
output "vmss_name" { value = azurerm_linux_virtual_machine_scale_set.vmss.name }
```

**Root `main.tf` — calling the module twice**
```hcl
module "web_vmss" {
  source              = "./modules/vmss"
  name_prefix         = "web"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.web.id
  vm_sku              = "Standard_B1s"
  instance_count      = 1  # Keep at 1 to minimize cost
  admin_username      = var.admin_username
  ssh_public_key      = file(var.ssh_public_key_path)
  tags                = { Tier = "web", ManagedBy = "Terraform" }
}

module "api_vmss" {
  source              = "./modules/vmss"
  name_prefix         = "api"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.api.id
  vm_sku              = "Standard_B1s"
  instance_count      = 1
  admin_username      = var.admin_username
  ssh_public_key      = file(var.ssh_public_key_path)
  tags                = { Tier = "api", ManagedBy = "Terraform" }
}
```

#### Verification Steps

```bash
# Confirm both scale sets were created
az vmss list --query "[].{Name:name, SKU:sku.name, Capacity:sku.capacity}" -o table

# Check module outputs
terraform output

# Scale the web vmss up to 2 (test, then scale back to 1)
az vmss scale --resource-group rg-az104-w5 \
  --name web-vmss --new-capacity 2
# Then scale back:
az vmss scale --resource-group rg-az104-w5 \
  --name web-vmss --new-capacity 1
```

#### ⚠️ Cost Warning
- **Two B1s VMSS at 1 instance each**: ~$15/month combined.[3]
- **Deploy only during study hours** and destroy immediately after.
- Keep `instance_count = 1` in both modules.

#### 🧹 Clean-Up Command
```bash
terraform destroy -auto-approve
# Verify no VMSS instances remain:
az vmss list -o table
```

***

## Week 6 — Networking: VNets, Peering, and Security Groups

### AZ-104 Domain Focus
**Configure and Manage Virtual Networking (15–20%):** VNet design and subnetting, Network Security Groups (NSGs), VNet peering (local and global), Azure DNS, Route Tables (UDRs), VPN Gateway basics, and Azure Bastion. This is the most hands-on domain in the exam.[23][24]

### Terraform Concept Focus
**`for_each`, `count`, and Dynamic Blocks** — Using `for_each` with maps to deploy multiple spoke VNets from a single resource block, `count` for NSG rule sets, and `dynamic` blocks to generate NSG security rules from a variable-defined list.[25][26][27]

📚 **Deep-Dive Links**
- [AZ-104: Configure Virtual Networks — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-virtual-networks/)[23]
- [Deploy Hub-Spoke Network Using Terraform — Blog Tutorial](https://johanvanneuville.com/automation/deploy-a-hub-spoke-network-using-terraform/)[28]
- [Create Hub-and-Spoke with Terraform — Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/terraform/hub-spoke-introduction)[29]
- [How to Use Terraform `for_each` — Spacelift Guide](https://spacelift.io/blog/terraform-for-each)[27]
- [Dynamic Blocks — HashiCorp Docs](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks)[26]

***

### Mini-Project: Hub-and-Spoke VNet with `for_each` Peering

**Scenario:** Deploy a Hub VNet and two Spoke VNets (dev and prod) using `for_each` on a map variable. Use dynamic blocks to generate NSG rules from a list. Establish bidirectional VNet peering between hub and each spoke.

**Estimated Time:** 6 hours (1 hr reading + 4 hrs build + 1 hr verify/cleanup)

#### Step-by-Step Task List (HCL)

**`variables.tf`**
```hcl
variable "spoke_vnets" {
  type = map(object({
    address_space = string
    subnet_prefix = string
    env           = string
  }))
  default = {
    dev = {
      address_space = "10.1.0.0/16"
      subnet_prefix = "10.1.1.0/24"
      env           = "dev"
    }
    prod = {
      address_space = "10.2.0.0/16"
      subnet_prefix = "10.2.1.0/24"
      env           = "prod"
    }
  }
}

variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    destination_port_range     = string
    source_address_prefix      = string
  }))
  default = [
    { name = "AllowHTTP",  priority = 100, direction = "Inbound",
      access = "Allow", protocol = "Tcp", destination_port_range = "80",
      source_address_prefix = "*" },
    { name = "AllowHTTPS", priority = 110, direction = "Inbound",
      access = "Allow", protocol = "Tcp", destination_port_range = "443",
      source_address_prefix = "*" },
    { name = "AllowSSH",   priority = 120, direction = "Inbound",
      access = "Allow", protocol = "Tcp", destination_port_range = "22",
      source_address_prefix = "10.0.0.0/8" }
  ]
}
```

**`main.tf`**
```hcl
# Hub VNet
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { Role = "hub", ManagedBy = "Terraform" }
}

resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.255.0/27"]
}

# Spoke VNets using for_each
resource "azurerm_virtual_network" "spokes" {
  for_each            = var.spoke_vnets
  name                = "vnet-spoke-${each.key}"
  address_space       = [each.value.address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { Role = "spoke", Env = each.value.env, ManagedBy = "Terraform" }
}

resource "azurerm_subnet" "spoke_subnets" {
  for_each             = var.spoke_vnets
  name                 = "snet-main-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spokes[each.key].name
  address_prefixes     = [each.value.subnet_prefix]
}

# Hub-to-spoke peering (for_each)
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each                  = var.spoke_vnets
  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spokes[each.key].id
  allow_forwarded_traffic   = true
}

# Spoke-to-hub peering (for_each)
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                  = var.spoke_vnets
  name                      = "peer-${each.key}-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spokes[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

# NSG with dynamic rules from variable
resource "azurerm_network_security_group" "spoke_nsg" {
  for_each            = var.spoke_vnets
  name                = "nsg-spoke-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = "*"
    }
  }
}
```

#### Verification Steps

```bash
# Confirm all VNets (hub + 2 spokes)
az network vnet list --query "[].{Name:name, AddressSpace:addressSpace.addressPrefixes[0]}" -o table

# Verify peering state (both sides should be "Connected")
az network vnet peering list \
  --vnet-name vnet-hub \
  --resource-group rg-az104-w6 \
  -o table

# Check NSG rules were created from dynamic block
az network nsg rule list \
  --nsg-name nsg-spoke-dev \
  --resource-group rg-az104-w6 \
  -o table

# Confirm hub-to-spoke peering allows forwarded traffic
az network vnet peering show \
  --name peer-hub-to-dev \
  --vnet-name vnet-hub \
  --resource-group rg-az104-w6 \
  --query "{State:peeringState, ForwardTraffic:allowForwardedTraffic}" -o table
```

#### ⚠️ Cost Warning
- **VNets, Subnets, NSGs, and VNet Peerings**: Peering within the same region costs ~$0.01/GB transferred — minimal in a lab.[30]
- **No VMs deployed this week** — zero compute cost.
- `azurerm_subnet.hub_gateway` (GatewaySubnet) is free unless a VPN Gateway is attached — **do not deploy a VPN Gateway** this week (costs ~$27/month).

#### 🧹 Clean-Up Command
```bash
terraform destroy -auto-approve
# Verify peerings are removed:
az network vnet peering list --vnet-name vnet-hub \
  --resource-group rg-az104-w6 -o table
```

***

## Week 7 — Networking Advanced: Load Balancing and DNS

### AZ-104 Domain Focus
**Configure and Manage Virtual Networking (Advanced):** Azure Load Balancer (Basic vs Standard), Application Gateway, Azure DNS (public/private zones, A/CNAME records), Azure Firewall (concepts), and Traffic Manager. Load Balancer configuration (health probes, backend pools, rules) is a high-frequency exam topic.[31][23]

### Terraform Concept Focus
**Conditional Expressions and Built-in Functions** — Using ternary conditionals to toggle resources by environment, `for` expressions to transform collections, `lookup()` / `merge()` / `flatten()` functions, and the `count = var.condition ? 1 : 0` pattern for optional resources.[32][26]

📚 **Deep-Dive Links**
- [AZ-104: Configure Virtual Networks — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-manage-virtual-networks/)[23]
- [Conditional Expressions — HashiCorp Docs](https://developer.hashicorp.com/terraform/language/expressions/conditionals)[32]
- [Preparing for AZ-104: Implement and Manage Virtual Networking (Ep. 4 of 5)](https://learn.microsoft.com/en-us/shows/exam-readiness-zone/preparing-for-az-104-implement-and-manage-virtual-networking-4-of-5)[24]

***

### Mini-Project: Conditional Load Balancer + DNS Factory

**Scenario:** Build an Azure Load Balancer (Basic SKU — free) fronting 2 B1s VMs. Use conditional logic to deploy a Standard LB only if `var.use_standard_lb = true`. Add an Azure Private DNS Zone with records generated via a `for` expression loop.

**Estimated Time:** 6 hours (1 hr reading + 4 hrs build + 1 hr verify/cleanup)

#### Step-by-Step Task List (HCL)

**Key variable for conditional logic:**
```hcl
variable "use_standard_lb" {
  type        = bool
  description = "Set true for Standard LB (costs money), false for Basic (free)"
  default     = false   # Keep false during study to avoid charges
}

variable "backend_vms" {
  type = map(object({ private_ip = string }))
  default = {
    vm01 = { private_ip = "10.0.1.10" }
    vm02 = { private_ip = "10.0.1.11" }
  }
}

variable "dns_records" {
  type = map(string)
  default = {
    "api"  = "10.0.1.10"
    "web"  = "10.0.1.11"
    "db"   = "10.0.2.10"
  }
}
```

**`main.tf` — Conditional Load Balancer + DNS**
```hcl
locals {
  lb_sku = var.use_standard_lb ? "Standard" : "Basic"
  pip_allocation = var.use_standard_lb ? "Static" : "Dynamic"
}

resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-lb-${local.lb_sku}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = local.pip_allocation
  sku                 = local.lb_sku
}

resource "azurerm_lb" "main" {
  name                = "lb-main-${lower(local.lb_sku)}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = local.lb_sku

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/health"
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "internal" {
  name                = "internal.az104lab.local"
  resource_group_name = azurerm_resource_group.rg.name
}

# DNS A records — generated from variable map using for_each
resource "azurerm_private_dns_a_record" "records" {
  for_each            = var.dns_records
  name                = each.key
  zone_name           = azurerm_private_dns_zone.internal.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [each.value]
}

# Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "dns-link-main"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}
```

#### Verification Steps

```bash
# Confirm LB was created with correct SKU
az network lb show \
  --name lb-main-basic \
  --resource-group rg-az104-w7 \
  --query "{Name:name, SKU:sku.name, FrontendIP:frontendIPConfigurations[0].name}" \
  -o table

# List all LB rules
az network lb rule list \
  --lb-name lb-main-basic \
  --resource-group rg-az104-w7 \
  -o table

# Confirm private DNS zone
az network private-dns zone list \
  --query "[].{Name:name, RG:resourceGroup}" \
  -o table

# List DNS A records
az network private-dns record-set a list \
  --zone-name internal.az104lab.local \
  --resource-group rg-az104-w7 \
  -o table

# Test conditional logic: apply with Standard LB
terraform apply -var="use_standard_lb=true" -auto-approve
terraform apply -var="use_standard_lb=false" -auto-approve
```

#### ⚠️ Cost Warning
- **Basic LB SKU**: **FREE** — default in this project.[33]
- **Standard LB SKU**: ~$18/month + data processing fees — only test briefly, then revert.
- **Standard Public IP**: ~$3.60/month — Standard LB requires a Static Standard PIP.
- **Private DNS Zone**: ~$0.50/month/zone (negligible, destroy when done).

#### 🧹 Clean-Up Command
```bash
# Ensure you've reverted to Basic LB before destroying (saves confusion):
terraform apply -var="use_standard_lb=false" -auto-approve
terraform destroy -auto-approve
```

***

## Week 8 — Monitor & Backup: Full-Stack Capstone

### AZ-104 Domain Focus
**Monitor and Maintain Azure Resources (10–15%):** Azure Monitor metrics and alerts, Log Analytics Workspace, Diagnostic Settings, Azure Backup policies (VM backup, file shares), Recovery Services Vault, and Azure Site Recovery concepts.[34]

### Terraform Concept Focus
**`terraform_remote_state` Data Sources and Advanced Functions** — Reading outputs from a previously applied Terraform state (e.g., the Week 6 networking stack) to wire monitoring to existing infrastructure, using `try()`, `coalesce()`, and `toset()` functions.[35][32]

📚 **Deep-Dive Links**
- [AZ-104: Monitor and Back Up Azure Resources — Microsoft Learn](https://learn.microsoft.com/en-us/training/paths/az-104-monitor-backup-resources/)[34]
- [The `terraform_remote_state` Data Source — HashiCorp Docs](https://developer.hashicorp.com/terraform/language/state/remote-state-data)[35]
- [Exam Content List: Terraform Associate 004 — HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004)[6]

***

### Mini-Project: Monitoring & Backup Capstone with Remote State

**Scenario:** Deploy a Log Analytics Workspace, wire it to the VM from Week 4 (read via `terraform_remote_state`), configure Azure Monitor diagnostic settings and a CPU alert rule, and set up an Azure Backup policy for the VM — all without re-deploying the underlying infrastructure.

**Estimated Time:** 6 hours (1.5 hrs reading + 3.5 hrs build + 1 hr verify/capstone cleanup)

#### Step-by-Step Task List (HCL)

**`data.tf` — Read prior state with `terraform_remote_state`**
```hcl
# Read the Week 4 VM deployment state
data "terraform_remote_state" "compute" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-backend"
    storage_account_name = "tfstateXXXXXX"
    container_name       = "tfstate"
    key                  = "week4/compute.tfstate"  # from Week 4
  }
}

locals {
  # Use try() to handle case where Week 4 state may not have all outputs
  vm_id = try(data.terraform_remote_state.compute.outputs.vm_id, "")
  vm_rg = try(data.terraform_remote_state.compute.outputs.resource_group_name, var.fallback_rg)
}
```

**`main.tf`**
```hcl
resource "azurerm_resource_group" "monitor" {
  name     = "rg-monitoring-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# Log Analytics Workspace (Free 500MB/day for 31 days)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-az104-${var.environment}"
  location            = azurerm_resource_group.monitor.location
  resource_group_name = azurerm_resource_group.monitor.name
  sku                 = "PerGB2018"
  retention_in_days   = 30  # Minimum retention, minimizes cost
  daily_quota_gb      = 0.5  # Cap at 500MB/day to stay in free tier
  tags                = local.common_tags
}

# Diagnostic settings on the VM from Week 4 (if it exists)
resource "azurerm_monitor_diagnostic_setting" "vm_diag" {
  count              = local.vm_id != "" ? 1 : 0
  name               = "diag-vm-to-law"
  target_resource_id = local.vm_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Action Group for alerts (email notification)
resource "azurerm_monitor_action_group" "email_alert" {
  name                = "ag-email-ops"
  resource_group_name = azurerm_resource_group.monitor.name
  short_name          = "OpsAlert"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }
}

# CPU alert rule on the VM
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count               = local.vm_id != "" ? 1 : 0
  name                = "alert-cpu-high"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [local.vm_id]
  description         = "Alert when CPU exceeds 80% for 5 minutes"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
  }
}

# Recovery Services Vault for VM Backup
resource "azurerm_recovery_services_vault" "vault" {
  name                = "rsv-az104-${var.environment}"
  location            = azurerm_resource_group.monitor.location
  resource_group_name = azurerm_resource_group.monitor.name
  sku                 = "Standard"   # Required (no free tier, but minimal cost)
  soft_delete_enabled = false        # Disable to allow clean destroy
  tags                = local.common_tags
}

# Backup policy (daily, 7-day retention)
resource "azurerm_backup_policy_vm" "daily" {
  name                = "policy-daily-7day"
  resource_group_name = azurerm_resource_group.monitor.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}
```

**`outputs.tf`** — Export outputs for potential downstream `remote_state` use
```hcl
output "law_workspace_id" {
  value = azurerm_log_analytics_workspace.law.workspace_id
}
output "law_primary_key" {
  value     = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive = true
}
output "recovery_vault_id" {
  value = azurerm_recovery_services_vault.vault.id
}
```

#### Verification Steps

```bash
# Confirm Log Analytics Workspace
az monitor log-analytics workspace show \
  --workspace-name law-az104-learning \
  --resource-group rg-monitoring-learning \
  --query "{Name:name, SKU:sku, RetentionDays:retentionInDays}" \
  -o table

# Verify alert rules
az monitor metrics alert list \
  --resource-group rg-monitoring-learning \
  -o table

# Check action group
az monitor action-group list \
  --resource-group rg-monitoring-learning \
  -o table

# Confirm Recovery Services Vault
az backup vault list \
  --resource-group rg-monitoring-learning \
  -o table

# Validate remote_state data was read (check plan output)
terraform plan 2>&1 | grep "remote_state"

# Run a test Log Analytics query in Portal:
# Heartbeat | summarize LastCall = max(TimeGenerated) by Computer
```

#### ⚠️ Cost Warning
- **Log Analytics**: First 5 GB/month is free; minimal cost with the 500MB/day cap.[30]
- **Recovery Services Vault + Backup Policy**: ~$0.02/GB/month for Protected Instance — minimal with small VM. **Note:** There is a 14-day soft-delete lock by default; setting `soft_delete_enabled = false` in the HCL above allows clean Terraform destroy.
- **Alert Rules**: Free up to 1,000 metric alert rules.
- **Total estimated Week 8 cost**: <$2 if deployed only during study time.

#### 🧹 Complete Course Clean-Up

```bash
# Week 8 resources
terraform destroy -auto-approve

# Verify all resource groups are removed
az group list --query "[?contains(name,'az104')]" -o table

# If backend storage is no longer needed:
az group delete --name rg-tfstate-backend --yes --no-wait

# Run a final cost check in Azure Portal:
# Cost Management → Cost Analysis → Last 30 Days
```

***

## Terraform Associate Exam Readiness Tracker

Use this checklist alongside the 8-week projects to ensure Terraform exam coverage:

| Objective Area | Week Covered | Terraform Concept Practiced |
|---------------|-------------|----------------------------|
| IaC concepts and Terraform workflow | Week 1 | `init`, `plan`, `apply`, `destroy`[2] |
| Providers and configuration | Week 1 | `azurerm` + `azuread` providers[9] |
| Variables, outputs, local values | Weeks 1–2 | `variable`, `output`, `locals`[8] |
| State management (local) | Weeks 1–2 | `terraform.tfstate`, `terraform state list`[16] |
| Remote backends | Week 3 | Azure Blob backend, state migration[17] |
| Workspaces | Week 4 | `terraform workspace new/select`[20] |
| Provisioners | Week 4 | `remote-exec` (use sparingly)[5] |
| Modules (authoring + calling) | Week 5 | Local child modules, `source`, inputs/outputs[22] |
| `for_each` and `count` | Week 6 | Map iteration for VNets and peerings[27] |
| Dynamic blocks | Week 6 | NSG rule generation from variable list[26] |
| Conditional expressions | Week 7 | Ternary conditions, `count = var.x ? 1 : 0`[32] |
| Built-in functions | Week 7 | `try()`, `lookup()`, `merge()`, `toset()`[6] |
| `terraform_remote_state` | Week 8 | Cross-stack data source[35] |
| HCP Terraform (workspaces, VCS) | Post-course | Review [HCP Terraform Docs](https://developer.hashicorp.com/terraform/cloud-docs)[5] |
| Lifecycle rules (`create_before_destroy`) | Post-course | [Lifecycle Docs](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)[2] |

***

## Supplemental Resources

### AZ-104 Official Microsoft Learn Paths (Complete Series)

| Path | Link |
|------|------|
| Prerequisites | [learn.microsoft.com/…/az-104-administrator-prerequisites](https://learn.microsoft.com/en-us/training/paths/az-104-administrator-prerequisites/)[36] |
| Identities & Governance | [learn.microsoft.com/…/az-104-manage-identities-governance](https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/)[7] |
| Storage | [learn.microsoft.com/…/az-104-manage-storage](https://learn.microsoft.com/en-us/training/paths/az-104-manage-storage/)[14] |
| Compute | [learn.microsoft.com/…/az-104-manage-compute-resources](https://learn.microsoft.com/en-us/training/paths/az-104-manage-compute-resources/)[19] |
| Virtual Networking | [learn.microsoft.com/…/az-104-manage-virtual-networks](https://learn.microsoft.com/en-us/training/paths/az-104-manage-virtual-networks/)[23] |
| Monitor & Backup | [learn.microsoft.com/…/az-104-monitor-backup-resources](https://learn.microsoft.com/en-us/training/paths/az-104-monitor-backup-resources/)[34] |

### Terraform Associate 004 Official Resources

| Resource | Link |
|----------|------|
| Certification page | [developer.hashicorp.com/certifications/infrastructure-automation](https://developer.hashicorp.com/certifications/infrastructure-automation)[2] |
| Study guide (004) | [developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004)[37] |
| Exam content list | [developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004)[6] |
| Azure provider docs | [registry.terraform.io/providers/hashicorp/azurerm/latest/docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)[10] |
| Azure get-started tutorials | [developer.hashicorp.com/terraform/tutorials/azure-get-started](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-variables)[9] |
| Dynamic blocks docs | [developer.hashicorp.com/terraform/language/expressions/dynamic-blocks](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks)[26] |
| `terraform_remote_state` docs | [developer.hashicorp.com/terraform/language/state/remote-state-data](https://developer.hashicorp.com/terraform/language/state/remote-state-data)[35] |

### Cost Optimization Quick Reference

| Situation | Recommendation |
|-----------|----------------|
| Need a VM for lab | Use `Standard_B1s` (~$7.59/month)[3]; deallocate after use |
| Storage for state/data | `Standard_LRS` StorageV2 (~$0.018/GB Hot)[18] |
| Load balancer | `Basic` SKU is free for labs[31] |
| Log Analytics | Set `daily_quota_gb = 0.5` to stay in free tier[30] |
| Recovery Vault | Set `soft_delete_enabled = false` for easy cleanup |
| Avoid surprise costs | Run `az cost management` weekly; use Azure Budget alerts |
| Nuclear option | `az group list --query "[?contains(name,'az104')]" | xargs ...` |