# Learning Path: Week 1 - Identities & Governance with Terraform

## Goal

Learn the Azure identity and governance concepts behind a small foundational environment, then use Terraform to express that setup clearly and repeatably.

By the end of this path, I should be able to:
- Explain the Azure concepts involved in a basic governed subscription foundation:
  - Microsoft Entra ID users and groups
  - Azure RBAC scopes and assignments
  - Azure Policy assignments
  - resource groups and tagging expectations
- Read and write a small Terraform configuration that uses both the `azurerm` and `azuread` providers.
- Separate Terraform structure from environment-specific values using variables and `terraform.tfvars`.
- Apply and destroy the Week 1 starter safely while understanding what each resource does in Azure.

## Audience and starting point

Assume:
- I am learning Azure administration first and Terraform second.
- I want to understand why each Azure object exists before I automate it.
- I am comfortable with basic terminal usage and Git.
- I have access to an Azure subscription and a Microsoft Entra tenant where I can create practice users, groups, and RBAC assignments.

If any of these assumptions are false, slow down and handle the missing prerequisite first.

## Final deliverable

A small but realistic Week 1 Terraform project in `Week 1 - Identity & Governance/` that:

- Creates:
  - a resource group
  - an Entra ID security group
  - a practice Entra ID user
  - a group membership linking that user to the group
  - an RBAC assignment at the resource group scope
  - an Azure Policy assignment that enforces the `Environment` tag
- Uses:
  - `providers.tf` for provider setup
  - `variables.tf` for typed inputs
  - `terraform.tfvars` for actual values
  - `main.tf` for the core resources
- Includes:
  - a `README.md` explaining how to init, plan, apply, verify, and destroy
  - at least one output or CLI verification step that helps inspect what Terraform created

The result should be something I can reuse as a starter for future Azure governance labs.

## Prerequisites

Before starting, I should:

- Have Terraform installed and available on my PATH.
- Have the Azure CLI installed and be able to run `az login`.
- Be signed into the correct tenant and subscription.
- Understand at a high level:
  - what a resource group is
  - what an Entra ID user and group are
  - what RBAC does
  - what Azure Policy is used for
- Have permissions that are sufficient for this lab.

For this project, permission checks matter more than usual. I may need:
- permission to create resource groups in the target subscription
- permission to assign Azure roles at the resource group scope
- permission to create Entra ID users and groups in the tenant

If any prerequisite is missing, guide me through the shortest setup or permissions check first.

## Scope boundaries

What is in scope:
- Azure subscription structure at a practical level:
  - tenant
  - subscription
  - resource group
  - scoped RBAC
- Microsoft Entra ID basics for admins:
  - users
  - groups
  - group membership
- Azure governance basics:
  - tags
  - policy assignment at resource group scope
  - least-privilege thinking, even if the starter uses a built-in role
- Terraform fundamentals needed for this lab:
  - providers
  - variables
  - `terraform.tfvars`
  - references between resources
  - basic plan/apply/destroy workflow

What is not in scope for this path:
- complex enterprise identity design
- conditional access, PIM, B2B, or hybrid identity
- management groups or large multi-subscription hierarchies
- custom Azure Policy definitions
- advanced Terraform modules or remote backends
- production-safe secret handling patterns beyond discussing the risks

Those can become later learning paths.

## Learning outcomes

By the end of this path, I should be able to:

- Explain, in my own words:
  - why Terraform needs both the `azurerm` and `azuread` providers for this project
  - how Azure RBAC scope affects what access is granted
  - why a policy assignment does not create resources but still changes governance behavior
  - how variables and `terraform.tfvars` keep Terraform configurations reusable
- Identify which parts of this lab are Azure concepts versus Terraform mechanics.
- Predict, at a high level, what `terraform plan` should show before applying it.
- Verify the created objects in Azure CLI after apply.
- Destroy the lab safely and confirm nothing unexpected remains.

## Reference code

If a `reference/` directory with a completed Week 1 project exists in this repo:

- Treat it as the end state for this learning path.
- Do not show it to me at the beginning.
- You may inspect it to infer structure and lesson ordering.
- Only compare against it if I explicitly ask for a review or reference solution.

## Lesson sequence

Use this sequence unless I explicitly ask to jump ahead:

1. **Azure context and permission check**
   - confirm the tenant and subscription I am targeting
   - confirm I understand the Azure objects in the lab
   - verify I have the right permissions for Entra ID and RBAC work

2. **Provider setup and authentication**
   - inspect `providers.tf`
   - understand why `azurerm` and `azuread` are both required
   - run `terraform init` and confirm provider installation

3. **Variables and `terraform.tfvars`**
   - inspect `variables.tf` and `terraform.tfvars`
   - understand the difference between declaring variables and assigning values
   - decide which values should remain defaults versus live in `terraform.tfvars`

4. **Resource group and tagging foundation**
   - create or review the resource group in `main.tf`
   - connect tags back to governance, not just syntax
   - run `plan` and predict the resource group name and tags before apply

5. **Entra ID users and groups**
   - add or review the Entra group and practice user
   - understand why this lab uses a non-production practice account
   - connect group membership to how access is normally managed at scale

6. **RBAC assignment**
   - review the role assignment resource
   - explain the meaning of principal, role, and scope
   - verify the assignment with Azure CLI after apply

7. **Azure Policy assignment**
   - review the built-in policy definition used in the starter
   - understand what the assignment enforces and where it applies
   - verify the policy assignment exists at the resource group scope

8. **Verification and cleanup workflow**
   - use Azure CLI and `terraform state list` to verify what exists
   - run `terraform destroy` safely
   - confirm the practice lab is cleaned up and state is understood

9. **Review and reflection**
   - do a short quiz on Azure identity/governance concepts and Terraform basics
   - review the final file structure
   - identify what to learn next in Azure and in Terraform

## Step policy

For this path:

- One main task at a time.
- Target about 5 to 20 minutes per task.
- Always:
  - say the current lesson step
  - say why it matters in Azure terms first, then Terraform terms
  - give a clear success check
- After completion, verify:
  - Terraform commands succeed
  - Azure objects exist exactly where expected
  - I can explain what changed in Azure, not just what changed in HCL

If I seem to be struggling, split the current lesson into smaller checks instead of jumping ahead.

## Quiz policy for this path

Quiz after roughly:

- finishing lesson 3 (providers, variables, and `terraform.tfvars`)
- finishing lesson 6 (users, groups, and RBAC)
- finishing lesson 8 (policy, verification, and cleanup)

Quizzes should favor:
- explain-in-your-own-words questions
- small predict-the-plan questions
- realistic admin mistakes such as wrong tenant, wrong scope, or confusing provider responsibilities

## Common mistakes to watch for

Watch for and help me correct:

- logging into the wrong Azure tenant or subscription before planning or applying
- assuming the `azurerm` provider can manage Entra ID objects without the `azuread` provider
- hard-coding names or environment-specific values that should live in variables or `terraform.tfvars`
- misunderstanding the difference between Azure RBAC and Azure Policy
- assigning a role at the wrong scope
- using an unsafe practice user password without understanding the risk
- forgetting that some identity or RBAC operations can take time to propagate
- treating `terraform plan` as optional instead of the main safety check
- destroying the lab without first confirming what Terraform believes it manages

## Success criteria

I should consider Week 1 complete when I can:

- explain the purpose of each resource in `main.tf`
- run `terraform init`, `plan`, `apply`, and `destroy` without guesswork
- verify the resource group, group membership, RBAC assignment, and policy assignment with Azure CLI
- describe which parts of the project taught Azure governance concepts and which parts taught Terraform mechanics
- point to at least one thing I would improve next, such as outputs, stronger variable validation, or safer credential handling