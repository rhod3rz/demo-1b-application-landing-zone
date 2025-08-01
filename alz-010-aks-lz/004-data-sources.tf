#================================================================================================
# Data Sources - Add any data source imports in here.
#================================================================================================

data "azapi_client_config" "current" {}

# Get key vault to retrieve secrets.
data "azurerm_key_vault" "kv" {
  provider            = azurerm.management
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}

# Get vm specific secrets.
# data "azurerm_key_vault_secret" "kvs" {
#   for_each     = var.virtual_machines
#   name         = "KV-ADM-PSWD-${upper(each.key)}"
#   key_vault_id = data.azurerm_key_vault.kv.id
# }
