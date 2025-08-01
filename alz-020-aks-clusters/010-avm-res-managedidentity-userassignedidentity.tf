# Create managed identities.
module "avm-res-managedidentity-userassignedidentity" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  enable_telemetry    = var.enable_telemetry
  for_each            = { for k, v in var.uamis : k => v }
  location            = var.location
  resource_group_name = each.value.resource_group_name
  name                = each.key
}

# Create resource role assignments.
resource "azurerm_role_assignment" "ra_resource" {
  for_each             = { for k, v in var.uami_role_assignments_resource : k => v }
  principal_id         = module.avm-res-managedidentity-userassignedidentity[each.value.uami_name].principal_id
  scope                = "/subscriptions/${each.value.subscription_id}/resourceGroups/${each.value.resource_group_name}/providers/${each.value.resource_type}/${each.value.resource_name}"
  role_definition_name = each.value.role_definition_name
}

# Create resource group role assignments.
resource "azurerm_role_assignment" "ra_resource_group" {
  for_each             = { for k, v in var.uami_role_assignments_resource_groups : k => v }
  principal_id         = module.avm-res-managedidentity-userassignedidentity[each.value.uami_name].principal_id
  scope                = "/subscriptions/${each.value.subscription_id}/resourceGroups/${each.value.resource_group_name}"
  role_definition_name = each.value.role_definition_name
}
