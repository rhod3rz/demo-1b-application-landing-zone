# Create route tables.
module "avm-res-network-routetable" {
  source              = "Azure/avm-res-network-routetable/azurerm"
  version             = "0.3.1"
  enable_telemetry    = false
  for_each            = { for k, v in var.route_tables : k => v }
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                = each.key
  routes              = each.value.routes
  tags                = var.tags
}
