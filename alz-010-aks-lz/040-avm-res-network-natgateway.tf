# Create nat gateways.
module "avm-res-network-natgateway" {
  source                  = "Azure/avm-res-network-natgateway/azurerm"
  version                 = "0.2.1"
  enable_telemetry        = var.enable_telemetry
  for_each                = { for k, v in var.nat_gws : k => v }
  location                = var.location
  resource_group_name     = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                    = each.key
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  public_ip_prefix_length = each.value.public_ip_prefix_length
  public_ip_configuration = each.value.public_ip_configuration
}
