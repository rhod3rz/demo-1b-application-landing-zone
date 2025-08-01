# Create vnets & subnets.
module "avm-res-network-virtualnetwork-peering" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version  = "0.8.1"
  for_each = { for k, v in var.vnet_peerings : k => v }
  virtual_network = {
    resource_id = module.avm-res-network-virtualnetwork[each.value.virtual_network].resource_id
  }
  remote_virtual_network = {
    resource_id = "/subscriptions/${each.value.remote_subscription_id}/resourceGroups/${each.value.remote_resource_group}/providers/Microsoft.Network/virtualNetworks/${each.value.remote_virtual_network_name}"
  }
  name                                 = each.value.name
  allow_virtual_network_access         = each.value.allow_virtual_network_access
  allow_forwarded_traffic              = each.value.allow_forwarded_traffic
  allow_gateway_transit                = each.value.allow_gateway_transit
  use_remote_gateways                  = each.value.use_remote_gateways
  create_reverse_peering               = each.value.create_reverse_peering
  reverse_name                         = each.value.reverse_name
  reverse_allow_virtual_network_access = each.value.reverse_allow_virtual_network_access
  reverse_allow_forwarded_traffic      = each.value.reverse_allow_forwarded_traffic
  reverse_allow_gateway_transit        = each.value.reverse_allow_gateway_transit
  reverse_use_remote_gateways          = each.value.reverse_use_remote_gateways
}
