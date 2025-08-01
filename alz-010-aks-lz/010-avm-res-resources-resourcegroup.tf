# Create resource groups.
module "avm-res-resources-resourcegroup" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  enable_telemetry = var.enable_telemetry
  for_each         = { for k, v in var.resource_groups : k => v }
  name             = each.key
  location         = var.location
  role_assignments = each.value.role_assignments
  tags             = var.tags
}
