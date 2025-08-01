# Create application gateway for containers.
resource "azurerm_application_load_balancer" "alb" {
  for_each            = { for k, v in var.gateways : k => v }
  location            = var.location
  resource_group_name = each.value.resource_group_name
  name                = each.value.gateway_name
}

# Define locals to process multiple frontends per gateway.
locals {
  gateway_frontends_list = flatten([
    for gw_key, gw_val in var.gateways : [
      for fe_key, fe_val in gw_val.gateway_frontends : {
        key           = "${gw_key}-${fe_key}"
        gateway_name  = gw_val.gateway_name
        frontend_name = fe_key
      }
    ]
  ])
  gateway_frontends_map = {
    for item in local.gateway_frontends_list : item.key => item
  }
}
# output "name" { value = local.gateway_frontends_map }

# Create the agfc frontends.
resource "azurerm_application_load_balancer_frontend" "albf" {
  for_each                     = local.gateway_frontends_map
  name                         = each.value.frontend_name
  application_load_balancer_id = azurerm_application_load_balancer.alb[each.value.gateway_name].id
}

# Create the agfc subnet association.
resource "azurerm_application_load_balancer_subnet_association" "albsa" {
  for_each                     = { for k, v in var.gateways : k => v }
  name                         = each.value.subnet_name
  application_load_balancer_id = azurerm_application_load_balancer.alb[each.value.gateway_name].id
  subnet_id                    = each.value.subnet_id
}

# Define locals to process multiple cname records per frontend.
locals {
  cname_records_list = flatten([
    for gw_key, gw_val in var.gateways : [
      for fe_key, fe_val in gw_val.gateway_frontends : [
        for cname_key, cname_val in fe_val.dns_cname_records : {
          key           = "${gw_key}-${fe_key}-${cname_key}"
          gateway_name  = gw_val.gateway_name
          frontend_name = fe_key
          record_name   = cname_val.name
          zone_name     = cname_val.zone_name
          record_rg     = cname_val.resource_group_name
          ttl           = cname_val.ttl
        }
      ]
    ]
  ])
  cname_records_map = {
    for item in local.cname_records_list : item.key => item
  }
}
# output "name" { value = local.cname_records_map }

resource "azurerm_dns_cname_record" "dcr" {
  for_each            = local.cname_records_map
  name                = each.value.record_name
  zone_name           = each.value.zone_name
  resource_group_name = each.value.record_rg
  ttl                 = each.value.ttl
  record              = azurerm_application_load_balancer_frontend.albf["${each.value.gateway_name}-${each.value.frontend_name}"].fully_qualified_domain_name
}
