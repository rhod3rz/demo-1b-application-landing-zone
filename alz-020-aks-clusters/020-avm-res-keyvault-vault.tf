# Create a role assignments map using static and dynamic values.
# e.g. sp's we know before we run apply, but uami's are created during the run; this allows us to add both without having to run apply multiple times.
locals {
  dynamic_kv_role_assignments = {
    for kv_name, kv_data in var.key_vaults : kv_name => {
      for ra_name, ra_data in kv_data.role_assignments : ra_name => {
        principal_id                     = startswith(ra_data.principal_id_or_uami_name, "uami-") ? module.avm-res-managedidentity-userassignedidentity[ra_data.principal_id_or_uami_name].principal_id : ra_data.principal_id_or_uami_name
        role_definition_id_or_name       = ra_data.role_definition_id_or_name
        skip_service_principal_aad_check = ra_data.skip_service_principal_aad_check
      }
    }
  }
}
# output "dynamic_kv_role_assignments" { value = local.dynamic_kv_role_assignments }

# Create key vaults.
module "avm-res-keyvault-vault" {
  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  version                       = "0.9.1"
  enable_telemetry              = var.enable_telemetry
  for_each                      = { for k, v in var.key_vaults : k => v }
  location                      = var.location
  resource_group_name           = each.value.resource_group_name
  name                          = each.key
  tenant_id                     = data.azapi_client_config.current.tenant_id
  public_network_access_enabled = each.value.public_network_access_enabled
  network_acls = {
    bypass         = each.value.network_acls.bypass
    default_action = each.value.network_acls.default_action
    ip_rules = concat(
      each.value.network_acls.ip_rules,
      length(data.azurerm_public_ip_prefix.pip) > 0 ?
      [data.azurerm_public_ip_prefix.pip[0].ip_prefix] :
      []
    )
    virtual_network_subnet_ids = each.value.network_acls.virtual_network_subnet_ids
  }
  private_endpoints          = each.value.private_endpoints
  purge_protection_enabled   = each.value.purge_protection_enabled
  role_assignments           = local.dynamic_kv_role_assignments[each.key]
  sku_name                   = each.value.sku_name
  soft_delete_retention_days = each.value.soft_delete_retention_days
  diagnostic_settings        = each.value.diagnostic_settings
  tags                       = var.tags
}

# Create secrets.
ephemeral "random_password" "rp" {
  for_each         = var.secrets
  length           = each.value.length
  special          = true
  override_special = "!@#%+="
}
resource "azurerm_key_vault_secret" "kvs" {
  for_each         = var.secrets
  name             = each.key
  value_wo         = ephemeral.random_password.rp[each.key].result
  value_wo_version = each.value.value_wo_version
  key_vault_id     = module.avm-res-keyvault-vault[each.value.key_vault_name].resource_id
}
