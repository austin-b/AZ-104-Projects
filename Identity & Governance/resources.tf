########## Create Resource Groups
# prod resource group
resource "azurerm_resource_group" "prod" {
  name     = "rg-prod"
  location = "East US"
}
# dev resource group
resource "azurerm_resource_group" "dev" {
  name     = "rg-dev"
  location = "East US"
}
# staging resource group
resource "azurerm_resource_group" "staging" {
  name     = "rg-staging"
  location = "East US"
}

############ Create Users
module "users" {
  source = "./modules/users"

  users = {
    admin-user = {
      user_principal_name = "admin-user@taustinbennettgmail.onmicrosoft.com"
      display_name        = "Admin User"
      mail_nickname       = "adminuser"
      password            = var.default_user_password
    }
    dev-user = {
      user_principal_name = "dev-user@taustinbennettgmail.onmicrosoft.com"
      display_name        = "Dev User"
      mail_nickname       = "devuser"
      password            = var.default_user_password
    }
    readonly-user = {
      user_principal_name = "readonly-user@taustinbennettgmail.onmicrosoft.com"
      display_name        = "Readonly User"
      mail_nickname       = "readonlyuser"
      password            = var.default_user_password
    }
  }
}

############ Create Groups and Assign Users
# Create groups
resource "azuread_group" "admins" {
  display_name     = "Admins"
  security_enabled = true
}
resource "azuread_group" "devs" {
  display_name     = "Developers"
  security_enabled = true
}
resource "azuread_group" "viewers" {
  display_name     = "Viewers"
  security_enabled = true
}
# Add users to groups
resource "azuread_group_member" "admins" {
  group_object_id = azuread_group.admins.object_id
  member_object_id = module.users.user_ids["admin-user"]
}
resource "azuread_group_member" "devs" {
  group_object_id = azuread_group.devs.object_id
  member_object_id = module.users.user_ids["dev-user"]
}
resource "azuread_group_member" "viewers" {
  group_object_id = azuread_group.viewers.object_id
  member_object_id = module.users.user_ids["readonly-user"]
}

############ Create Role Assignments
# Admins get Owner role on prod resource group
resource "azurerm_role_assignment" "admins_prod" {
  scope = azurerm_resource_group.prod.id
  role_definition_name = "Owner"
  principal_id = azuread_group.admins.object_id
}
# Devs get Contributor role on dev resource group
resource "azurerm_role_assignment" "devs_dev" {
  scope = azurerm_resource_group.dev.id
  role_definition_name = "Contributor"
  principal_id = azuread_group.devs.object_id
}
# Viewers get Reader role on entire subscription
resource "azurerm_role_assignment" "viewers_all" {
  scope = "/subscriptions/${var.subscription_id}" # needs to be in this format for subscription-level scope
  role_definition_name = "Reader"
  principal_id = azuread_group.viewers.object_id
}

############ Create Policies
# ensure all resources have a CostCenter tag
resource "azurerm_policy_definition" "require_costcenter_tag" {
  name         = "require-costcenter-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Cost Center Tag"
  description   = "This policy requires that all resources have a 'CostCenter' tag."

  policy_rule = jsonencode({
  "if": {
    "field": "tags.CostCenter",
    "exists": "false"
  },
  "then": {
    "effect": "deny"
  }})
}

# Apply policy to all resource groups
resource "azurerm_resource_group_policy_assignment" "require_costcenter_tag_prod" {
  name = "require-costcenter-tag-prod"
  policy_definition_id = azurerm_policy_definition.require_costcenter_tag.id
  resource_group_id = azurerm_resource_group.prod.id
}
resource "azurerm_resource_group_policy_assignment" "require_costcenter_tag_dev" {
  name = "require-costcenter-tag-dev"
  policy_definition_id = azurerm_policy_definition.require_costcenter_tag.id
  resource_group_id = azurerm_resource_group.dev.id
}
resource "azurerm_resource_group_policy_assignment" "require_costcenter_tag_staging" {
  name = "require-costcenter-tag-staging"
  policy_definition_id = azurerm_policy_definition.require_costcenter_tag.id
  resource_group_id = azurerm_resource_group.staging.id
}

# Apply policy to subscription and only allow creation in East US and East US 2
resource "azurerm_subscription_policy_assignment" "limit_allowed_locations" {
  name = "limit-allowed-locations"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  subscription_id = "/subscriptions/${var.subscription_id}"

  parameters = jsonencode({
  "listOfAllowedLocations": {
    "value": [
      "eastus",
      "eastus2"
    ]
  }})
}

############ Add a "CanNotDelete" lock to prod resource group
resource "azurerm_management_lock" "prod_delete_lock" {
  name = "prod-delete-lock"
  scope = azurerm_resource_group.prod.id
  lock_level = "CanNotDelete"
  notes = "Protect Production RG from deletion."
}

############ Set up budget alerts for the subscription
resource "azurerm_consumption_budget_subscription" "monthly_recurring" {
  name = "monthly-budget"
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount = 100
  time_grain = "Monthly"

  time_period {
    start_date = "2026-04-01T00:00:00Z"
    end_date   = "2026-05-01T00:00:00Z"
  }

  notification {
    enabled = true
    threshold = 80
    operator = "EqualTo"
    threshold_type = "Forecasted"
    contact_emails = ["admin@example.com"]
  }

  notification {
    enabled = true
    threshold = 100
    operator = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = ["admin@example.com"]
  }
}