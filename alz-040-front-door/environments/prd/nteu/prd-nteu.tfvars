#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id  = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05" # appl_prd_01.
location         = "northeurope"
enable_telemetry = false
tags = {
  environment = "prd"
  owner       = "rhod3rz@outlook.com"
}

#================================================================================================
# 010-front-door.tf
#================================================================================================
front_door_profiles = {
  fd-prd-01 = {
    resource_group_name = "rg-prd-nteu-aks"
    sku_name            = "Standard_AzureFrontDoor"
  }
}

# If you see this error 'The requested operation cannot be executed on the entity in the current state.' ...
# you may need to wait 15 mins+ after creating step 1; there are vague reports online about this.
front_door_endpoints = {
  prd = { # prepended to name e.g. prd-fzdsb3abeugpfrcm.z03.azurefd.net.
    cdn_frontdoor_profile = "fd-prd-01"
    # custom domains
    custom_domains = {
      cd-cart-rhod3rz-com = {
        host_name        = "cart.rhod3rz.com"
        dns_txt_record   = "_dnsauth.cart"
        dns_zone_id      = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-core-01/providers/Microsoft.Network/dnsZones/rhod3rz.com"
        dns_zone_id_name = "rhod3rz.com"
        dns_zone_id_rg   = "rg-core-01"
        dns_cname_record = {
          name                = "cart"
          zone_name           = "rhod3rz.com"
          resource_group_name = "rg-core-01"
          ttl                 = 300
        }
        dns_a_record = null
      }
      cd-catalog-rhod3rz-com = {
        host_name        = "catalog.rhod3rz.com"
        dns_txt_record   = "_dnsauth.catalog"
        dns_zone_id      = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-core-01/providers/Microsoft.Network/dnsZones/rhod3rz.com"
        dns_zone_id_name = "rhod3rz.com"
        dns_zone_id_rg   = "rg-core-01"
        dns_cname_record = {
          name                = "catalog"
          zone_name           = "rhod3rz.com"
          resource_group_name = "rg-core-01"
          ttl                 = 300
        }
        dns_a_record = null
      }
    }
    # origin groups (aka origin_group_key)
    origin_groups = {
      og-cart-rhod3rz-com = {
        name                     = "og-cart-rhod3rz-com"
        session_affinity_enabled = false
        load_balancing = {
          sample_size                        = 4
          successful_samples_required        = 3
          additional_latency_in_milliseconds = 500
        }
        health_probe = {
          path                = "/liveness"
          request_type        = "HEAD"
          protocol            = "Https"
          interval_in_seconds = 255
        }
      }
      og-catalog-rhod3rz-com = {
        name                     = "og-catalog-rhod3rz-com"
        session_affinity_enabled = false
        load_balancing = {
          sample_size                        = 4
          successful_samples_required        = 3
          additional_latency_in_milliseconds = 500
        }
        health_probe = {
          path                = "/liveness"
          request_type        = "HEAD"
          protocol            = "Https"
          interval_in_seconds = 255
        }
      }
    }
    # origins (aka origin_key)
    origins = {
      o-cart-rhod3rz-com = {
        name                           = "o-cart-rhod3rz-com"
        origin_group_key               = "og-cart-rhod3rz-com"
        host_name                      = "agfc.prd.grn.mango.cart.rhod3rz.com"
        origin_host_header             = "agfc.prd.grn.mango.cart.rhod3rz.com"
        http_port                      = 80
        https_port                     = 443
        priority                       = 1
        weight                         = 50
        certificate_name_check_enabled = false # << false for staging cert-manager | true for production cert-manager.
        enabled                        = true
      }
      o-catalog-rhod3rz-com = {
        name                           = "o-catalog-rhod3rz-com"
        origin_group_key               = "og-catalog-rhod3rz-com"
        host_name                      = "agfc.prd.grn.mango.catalog.rhod3rz.com"
        origin_host_header             = "agfc.prd.grn.mango.catalog.rhod3rz.com"
        http_port                      = 80
        https_port                     = 443
        priority                       = 1
        weight                         = 50
        certificate_name_check_enabled = false # << false for staging cert-manager | true for production cert-manager.
        enabled                        = true
      }
    }
    # routes
    routes = {
      r-cart-rhod3rz-com = {
        name                   = "r-cart-rhod3rz-com"
        enabled                = true
        link_to_default_domain = false
        custom_domain_keys     = ["cd-cart-rhod3rz-com"]
        patterns_to_match      = ["/*"]
        supported_protocols    = ["Http", "Https"]
        https_redirect_enabled = true
        origin_group_keys      = ["og-cart-rhod3rz-com"]
        origin_keys            = ["o-cart-rhod3rz-com"] # weird that azurerm wants this; but its a required field so we include it.
        forwarding_protocol    = "MatchRequest"
      }
      r-catalog-rhod3rz-com = {
        name                   = "r-catalog-rhod3rz-com"
        enabled                = true
        link_to_default_domain = false
        custom_domain_keys     = ["cd-catalog-rhod3rz-com"]
        patterns_to_match      = ["/*"]
        supported_protocols    = ["Http", "Https"]
        https_redirect_enabled = true
        origin_group_keys      = ["og-catalog-rhod3rz-com"]
        origin_keys            = ["o-catalog-rhod3rz-com"] # weird that azurerm wants this; but its a required field so we include it.
        forwarding_protocol    = "MatchRequest"
      }
    }
  }
}
# note: once created it can take a few minutes for the website to start working; you'll get various errors until then.
# example errors are:
# page not found and certificate errors
# 502 could be due to using staging cert-manager cert; check certificate_name_check_enabled
