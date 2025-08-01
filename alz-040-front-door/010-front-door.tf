# 1. CDN profile.
# This only runs for nonprod and prod as you only need a single front door per environment.
resource "azurerm_cdn_frontdoor_profile" "cfp" {
  for_each            = { for k, v in var.front_door_profiles : k => v }
  name                = each.key
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
}

# 2. Endpoint.
# If you see this error 'The requested operation cannot be executed on the entity in the current state.' ...
# you may need to wait 15 mins+ after creating step 1; there are vague reports online about this.
resource "azurerm_cdn_frontdoor_endpoint" "cfe" {
  for_each                 = { for k, v in var.front_door_endpoints : k => v }
  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cfp[each.value.cdn_frontdoor_profile].id
}

# 3. Custom domain.
# Locals map to allow multiple custom domains per endpoint.
locals {
  front_door_custom_domains = flatten([
    for endpoint_key, endpoint in var.front_door_endpoints : [
      for domain_key, domain in endpoint.custom_domains : {
        key              = "${endpoint_key}-${domain_key}"
        profile_id       = azurerm_cdn_frontdoor_profile.cfp[endpoint.cdn_frontdoor_profile].id
        name             = domain_key
        host_name        = domain.host_name
        dns_txt_record   = domain.dns_txt_record
        dns_zone_id      = domain.dns_zone_id
        dns_zone_id_name = domain.dns_zone_id_name
        dns_zone_id_rg   = domain.dns_zone_id_rg
      }
    ]
  ])
  # All domains.
  front_door_custom_domain_map = {
    for item in local.front_door_custom_domains : item.key => item
  }
  # Only domains with DNS validation needed (non-null dns_zone_id).
  front_door_dns_validation_map = {
    for item in local.front_door_custom_domains :
    item.key => item
    if item.dns_zone_id != null && item.dns_txt_record != null && item.dns_zone_id_name != null && item.dns_zone_id_rg != null
  }
}
# output "front_door_custom_domain_map" { value = local.front_door_custom_domain_map }
# output "front_door_dns_validation_map" { value = local.front_door_dns_validation_map }
resource "azurerm_cdn_frontdoor_custom_domain" "cfcd" {
  for_each                 = local.front_door_custom_domain_map
  name                     = each.value.name
  cdn_frontdoor_profile_id = each.value.profile_id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.value.host_name
  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

# 4. Custom domain validation.
resource "azurerm_dns_txt_record" "dtr" {
  for_each            = local.front_door_dns_validation_map
  name                = each.value.dns_txt_record   # e.g._dnsauth.cart.
  zone_name           = each.value.dns_zone_id_name # e.g. rhod3rz.com.
  resource_group_name = each.value.dns_zone_id_rg
  ttl                 = 3600
  record {
    value = azurerm_cdn_frontdoor_custom_domain.cfcd[each.key].validation_token
  }
}

# 5. Origin groups.
# Locals map to allow multiple origin groups per endpoint.
locals {
  front_door_origin_groups_list = flatten([
    for endpoint_key, endpoint in var.front_door_endpoints : [
      for group_key, group in endpoint.origin_groups : {
        key                      = "${endpoint_key}-${group_key}"
        endpoint_key             = endpoint_key
        name                     = group.name
        profile_id               = azurerm_cdn_frontdoor_profile.cfp[endpoint.cdn_frontdoor_profile].id
        session_affinity_enabled = group.session_affinity_enabled
        load_balancing           = group.load_balancing
        health_probe             = group.health_probe
      }
    ]
  ])
  front_door_origin_groups_map = {
    for item in local.front_door_origin_groups_list : item.key => item
  }
}
# output "front_door_origin_groups_map" { value = local.front_door_origin_groups_map }
resource "azurerm_cdn_frontdoor_origin_group" "cfog" {
  for_each                 = local.front_door_origin_groups_map
  name                     = each.value.name
  cdn_frontdoor_profile_id = each.value.profile_id
  session_affinity_enabled = each.value.session_affinity_enabled
  load_balancing {
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
  }
  health_probe {
    path                = each.value.health_probe.path
    request_type        = each.value.health_probe.request_type
    protocol            = each.value.health_probe.protocol
    interval_in_seconds = each.value.health_probe.interval_in_seconds
  }
}
# output "azurerm_cdn_frontdoor_origin_group" { value = azurerm_cdn_frontdoor_origin_group.cfog }

# 6. Origins.
# Locals map to allow multiple origins per origin group.
locals {
  front_door_origins_list = flatten([
    for endpoint_key, endpoint in var.front_door_endpoints : [
      for origin_key, origin in endpoint.origins : [
        {
          key              = "${endpoint_key}-${origin_key}"
          origin_key       = origin_key
          endpoint_key     = endpoint_key
          origin_group_key = origin.origin_group_key
          origin           = origin
        }
      ]
    ]
  ])
  front_door_origins_map = {
    for item in local.front_door_origins_list : item.key => item
  }
}
# output "front_door_origins_map" { value = local.front_door_origins_map }
resource "azurerm_cdn_frontdoor_origin" "cfo" {
  for_each                       = local.front_door_origins_map
  name                           = each.value.origin.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.cfog["${each.value.endpoint_key}-${each.value.origin_group_key}"].id
  enabled                        = each.value.origin.enabled
  host_name                      = each.value.origin.host_name
  origin_host_header             = each.value.origin.origin_host_header
  http_port                      = each.value.origin.http_port
  https_port                     = each.value.origin.https_port
  priority                       = each.value.origin.priority
  weight                         = each.value.origin.weight
  certificate_name_check_enabled = each.value.origin.certificate_name_check_enabled
}

# 7. Routes.
# Locals map to allow multiple routes per endpoint.
locals {
  front_door_routes_list = flatten([
    for endpoint_key, endpoint in var.front_door_endpoints : [
      for route_key, route in endpoint.routes : {
        key                    = "${endpoint_key}-${route_key}"
        endpoint_key           = endpoint_key
        name                   = route.name
        enabled                = route.enabled
        link_to_default_domain = route.link_to_default_domain
        custom_domain_keys     = route.custom_domain_keys
        patterns_to_match      = route.patterns_to_match
        supported_protocols    = route.supported_protocols
        https_redirect_enabled = route.https_redirect_enabled
        origin_group_key       = route.origin_group_keys[0]
        origin_keys            = route.origin_keys
        forwarding_protocol    = route.forwarding_protocol
      }
    ]
  ])
  front_door_routes_map = {
    for item in local.front_door_routes_list : item.key => item
  }
}
# output "front_door_routes_map" { value = local.front_door_routes_map }
resource "azurerm_cdn_frontdoor_route" "cfr" {
  for_each                        = local.front_door_routes_map
  name                            = each.value.name
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.cfe[each.value.endpoint_key].id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.cfog["${each.value.endpoint_key}-${each.value.origin_group_key}"].id
  cdn_frontdoor_origin_ids        = [for origin_key in each.value.origin_keys : azurerm_cdn_frontdoor_origin.cfo["${each.value.endpoint_key}-${origin_key}"].id]
  cdn_frontdoor_custom_domain_ids = [for domain_key in each.value.custom_domain_keys : azurerm_cdn_frontdoor_custom_domain.cfcd["${each.value.endpoint_key}-${domain_key}"].id]
  supported_protocols             = each.value.supported_protocols
  patterns_to_match               = each.value.patterns_to_match
  forwarding_protocol             = each.value.forwarding_protocol
  link_to_default_domain          = each.value.link_to_default_domain
  https_redirect_enabled          = each.value.https_redirect_enabled
  enabled                         = each.value.enabled
}

# 8. Cname record mapping custom domain to front door fqdn.
# Locals map to allow multiple cname records per endpoint.
locals {
  front_door_cname_records = flatten([
    for endpoint_key, endpoint in var.front_door_endpoints : [
      for domain_key, domain in endpoint.custom_domains : (
        domain.dns_cname_record != null ? [{
          key                 = "${endpoint_key}-${domain_key}"
          name                = domain.dns_cname_record.name
          zone_name           = domain.dns_cname_record.zone_name
          resource_group_name = domain.dns_cname_record.resource_group_name
          ttl                 = domain.dns_cname_record.ttl
          endpoint_key        = endpoint_key
        }] : []
      )
    ]
  ])
  front_door_cname_map = {
    for item in local.front_door_cname_records : item.key => item
  }
}
# output "front_door_cname_map" { value = local.front_door_cname_map }
resource "azurerm_dns_cname_record" "dcr" {
  depends_on          = [azurerm_cdn_frontdoor_route.cfr]
  for_each            = local.front_door_cname_map
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  ttl                 = each.value.ttl
  record              = azurerm_cdn_frontdoor_endpoint.cfe[each.value.endpoint_key].host_name
}

# 9. An A name record mapping the apex domain to the front door endpoint.
# Locals map to allow multiple A name records per endpoint.
locals {
  front_door_a_records = flatten([
    for endpoint_key, endpoint in var.front_door_endpoints : [
      for domain_key, domain in endpoint.custom_domains : (
        domain.dns_a_record != null ? [{
          key                 = "${endpoint_key}-${domain_key}"
          name                = domain.dns_a_record.name
          zone_name           = domain.dns_a_record.zone_name
          resource_group_name = domain.dns_a_record.resource_group_name
          ttl                 = domain.dns_a_record.ttl
          target_resource_id  = "${azurerm_cdn_frontdoor_profile.cfp[domain.dns_a_record.front_door_profile].id}/afdendpoints/${endpoint_key}"
        }] : []
      )
    ]
  ])
  front_door_a_record_map = {
    for item in local.front_door_a_records : item.key => item
  }
}
# output "front_door_a_record_map" { value = local.front_door_a_record_map }
resource "azapi_resource" "apex_a_record" {
  for_each  = local.front_door_a_record_map
  type      = "Microsoft.Network/dnszones/A@2023-07-01-preview"
  name      = each.value.name != "" ? each.value.name : "@"
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${each.value.resource_group_name}/providers/Microsoft.Network/dnszones/${each.value.zone_name}"
  body = jsonencode({
    properties = {
      TTL = each.value.ttl
      targetResource = {
        id = each.value.target_resource_id
      }
      trafficManagementProfile = {}
    }
  })
}
# note: once created it can take a few minutes for the website to start working; you'll get various errors until then.
# example errors are:
# page not found and certificate errors
# 502 could be due to using staging cert-manager cert; check certificate_name_check_enabled
