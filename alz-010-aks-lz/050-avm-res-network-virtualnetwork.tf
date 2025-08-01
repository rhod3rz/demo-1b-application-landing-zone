# Create vnets & subnets.
module "avm-res-network-virtualnetwork" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  enable_telemetry    = var.enable_telemetry
  for_each            = { for k, v in var.spokes : k => v }
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                = each.value.name
  address_space       = each.value.address_space
  subnets = {
    for k, v in each.value.subnets : k => {
      name                            = v.subnet_name
      address_prefixes                = v.address_prefixes
      route_table                     = (v.route_table_name != "" ? { id = module.avm-res-network-routetable[v.route_table_name].resource_id } : null)
      nat_gateway                     = (v.nat_gateway_name != "" ? { id = module.avm-res-network-natgateway[v.nat_gateway_name].resource_id } : null)
      network_security_group          = (v.nsg_name != "" ? { id = module.avm-res-network-networksecuritygroup[v.nsg_name].resource_id } : null)
      default_outbound_access_enabled = v.default_outbound_access_enabled
      delegation                      = (v.delegation != "" ? v.delegation : null)
    }
  }
  role_assignments = each.value.role_assignments
  tags             = var.tags
}
