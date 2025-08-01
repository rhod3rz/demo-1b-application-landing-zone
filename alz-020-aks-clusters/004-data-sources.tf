#================================================================================================
# Data Sources - Add any data source imports in here.
#================================================================================================

# Get the tenant id for 020-avm-res-keyvault-vault.
data "azapi_client_config" "current" {}

# Get the nat gateway ip prefix for 040-avm-res-containerservice-managedcluster.
data "azurerm_nat_gateway" "ng" {
  count               = try(var.nat_gateway.name, null) != null ? 1 : 0
  name                = var.nat_gateway.name
  resource_group_name = var.nat_gateway.resource_group
}
data "azurerm_public_ip_prefix" "pip" {
  count               = length(data.azurerm_nat_gateway.ng) > 0 ? 1 : 0
  name                = basename(data.azurerm_nat_gateway.ng[0].public_ip_prefix_ids[0])
  resource_group_name = data.azurerm_nat_gateway.ng[0].resource_group_name
}

# Get the cluster resource to surface the oidc url for 050-federated-identity.
data "azurerm_kubernetes_cluster" "kc" {
  depends_on          = [module.avm-res-containerservice-managedcluster]
  for_each            = { for k, v in var.clusters : k => v }
  name                = module.avm-res-containerservice-managedcluster[each.key].name
  resource_group_name = each.value.resource_group_name
}
