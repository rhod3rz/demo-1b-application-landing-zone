# Create a role assignments map using static and dynamic values.
# e.g. sp's we know before we run apply, but uami's are created during the run; this allows us to add both without having to run apply multiple times.
locals {
  dynamic_acr_role_assignments = {
    for acr_name, acr_data in var.container_registrys : acr_name => {
      for ra_name, ra_data in acr_data.role_assignments : ra_name => {
        role_definition_id_or_name       = ra_data.role_definition_id_or_name
        principal_id                     = startswith(ra_data.principal_id_or_uami_name, "uami-") ? module.avm-res-managedidentity-userassignedidentity[ra_data.principal_id_or_uami_name].principal_id : ra_data.principal_id_or_uami_name
        skip_service_principal_aad_check = ra_data.skip_service_principal_aad_check
      }
    }
  }
}
# output "dynamic_acr_role_assignments" { value = local.dynamic_acr_role_assignments }

# Create container registrys.
module "avm-res-containerregistry-registry" {
  source                        = "Azure/avm-res-containerregistry-registry/azurerm"
  version                       = "0.4.0"
  enable_telemetry              = var.enable_telemetry
  for_each                      = { for k, v in var.container_registrys : k => v }
  location                      = var.location
  resource_group_name           = each.value.resource_group_name
  name                          = each.key
  sku                           = each.value.sku
  public_network_access_enabled = each.value.public_network_access_enabled
  private_endpoints             = each.value.private_endpoints
  georeplications               = each.value.georeplications
  network_rule_bypass_option    = each.value.network_rule_bypass_option
  zone_redundancy_enabled       = each.value.zone_redundancy_enabled
  retention_policy_in_days      = each.value.retention_policy_in_days
  role_assignments              = local.dynamic_acr_role_assignments[each.key]
  diagnostic_settings           = each.value.diagnostic_settings
  tags                          = var.tags
}

# Initial seeding of ACR with demo images for testing.
locals {
  demo_app_imports = {
    for registry_key, registry in var.container_registrys :
    registry_key => flatten([
      for image_key, image in lookup(registry, "demoapps", {}) : [
        {
          key           = "${registry_key}.${image_key}"
          registry_name = image.name
          source        = image.source
          image         = image.image
        }
      ]
    ])
  }
  flat_demo_app_imports = {
    for pair in flatten(values(local.demo_app_imports)) :
    pair.key => {
      registry_name = pair.registry_name
      source        = pair.source
      image         = pair.image
    }
  }
}
resource "null_resource" "import_demo_apps" {
  for_each = local.flat_demo_app_imports
  provisioner "local-exec" {
    command = <<EOT
      az acr import --name ${each.value.registry_name} --source ${each.value.source} --image ${each.value.image} --force
    EOT
  }
  depends_on = [module.avm-res-containerregistry-registry]
}
