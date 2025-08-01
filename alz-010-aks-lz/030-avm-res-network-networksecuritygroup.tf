# Create network security groups and rules.
module "avm-res-network-networksecuritygroup" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  enable_telemetry    = false
  for_each            = { for k, v in var.network_security_groups : k => v }
  location            = var.location
  resource_group_name = module.avm-res-resources-resourcegroup[each.value.resource_group_name].name
  name                = each.key
  security_rules = {
    for rule in csvdecode(file(each.value.security_rules)) :
    rule.name => {
      name                                       = rule.name
      priority                                   = rule.priority
      direction                                  = rule.direction
      access                                     = rule.access
      protocol                                   = rule.protocol
      source_port_range                          = rule.source_port_range != "" ? rule.source_port_range : null
      source_port_ranges                         = rule.source_port_ranges != "" ? split(",", rule.source_port_ranges) : null
      destination_port_range                     = rule.destination_port_range != "" ? rule.destination_port_range : null
      destination_port_ranges                    = rule.destination_port_ranges != "" ? split(",", rule.destination_port_ranges) : null
      source_address_prefix                      = rule.source_address_prefix != "" ? rule.source_address_prefix : null
      source_address_prefixes                    = rule.source_address_prefixes != "" ? split(",", rule.source_address_prefixes) : null
      source_application_security_group_ids      = rule.source_application_security_group_ids != "" ? split(",", rule.source_application_security_group_ids) : null
      destination_address_prefix                 = rule.destination_address_prefix != "" ? rule.destination_address_prefix : null
      destination_address_prefixes               = rule.destination_address_prefixes != "" ? split(",", rule.destination_address_prefixes) : null
      destination_application_security_group_ids = rule.destination_application_security_group_ids != "" ? split(",", rule.destination_application_security_group_ids) : null
      description                                = rule.description
    } if rule.name != ""
  }
  tags = var.tags
}
