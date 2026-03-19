## Project 1: Identity & Governance Foundation

**Domain:** Manage Azure identities and governance (20–25%)

### What You Build
A fully governed Azure environment with Entra ID users, groups, RBAC role assignments, Azure Policy, resource locks, tags, and management groups.

### Skills Covered
- Create users and groups in Microsoft Entra ID
- Configure self-service password reset (SSPR)
- Assign built-in Azure roles at different scopes (subscription, resource group, resource)
- Implement and manage Azure Policy (e.g., enforce tagging, restrict allowed locations)
- Configure resource locks (CanNotDelete, ReadOnly)
- Apply and manage tags on resources
- Manage resource groups and subscriptions
- Configure management groups

### Steps
1. Create a resource group hierarchy: `rg-prod`, `rg-dev`, `rg-staging`
2. Create Entra ID users: `admin-user`, `dev-user`, `readonly-user`
3. Create groups: `Admins`, `Developers`, `Viewers`
4. Assign RBAC roles: Contributor to Developers on `rg-dev`, Reader to Viewers on all RGs
5. Create an Azure Policy that enforces a `CostCenter` tag on all resources
6. Create a policy that restricts resource creation to `East US` and `East US 2` only
7. Apply resource locks on the `rg-prod` resource group
8. Set up budget alerts for cost management

### Terraform Components
``` hcl
# Key resources to define in Terraform:
azurerm_resource_group
azurerm_role_assignment
azurerm_policy_definition
azurerm_policy_assignment
azurerm_management_lock
azurerm_subscription_policy_assignment
azuread_user
azuread_group
azuread_group_member
```

### Documentation Write-Up Guidance
- **Architecture diagram:** Show management group → subscription → resource group hierarchy
- **Screenshot:** Policy compliance dashboard showing enforced policies
- **Explain:** Why RBAC follows least-privilege principles and how policy-as-code ensures governance at scale