# Create federated identitys.
resource "azurerm_federated_identity_credential" "fic" {
  for_each            = { for k, v in var.federated_identitys : k => v }
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  parent_id           = module.avm-res-managedidentity-userassignedidentity[each.value.parent_id].resource_id
  issuer              = data.azurerm_kubernetes_cluster.kc[each.value.issuer].oidc_issuer_url
  subject             = each.value.subject
  audience            = each.value.audience
  # added to prevent false updates to issuer on runs.
  lifecycle {
    ignore_changes = [
      issuer
    ]
  }
}
