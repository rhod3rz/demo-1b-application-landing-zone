# Create aks clusters.
module "avm-res-containerservice-managedcluster" {
  source                   = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version                  = "0.2.4"
  enable_telemetry         = var.enable_telemetry
  for_each                 = { for k, v in var.clusters : k => v }
  location                 = var.location
  resource_group_name      = each.value.resource_group_name
  node_resource_group_name = each.value.node_resource_group_name
  name                     = each.key
  api_server_access_profile = {
    authorized_ip_ranges = concat(
      each.value.api_server_access_profile.authorized_ip_ranges,
      length(data.azurerm_public_ip_prefix.pip) > 0 ?
      [data.azurerm_public_ip_prefix.pip[0].ip_prefix] :
      []
    )
  }
  automatic_upgrade_channel                        = each.value.automatic_upgrade_channel
  azure_active_directory_role_based_access_control = each.value.azure_active_directory_role_based_access_control
  kubernetes_version                               = each.value.kubernetes_version
  create_nodepools_before_destroy                  = each.value.create_nodepools_before_destroy
  default_node_pool = {
    name                 = each.value.default_node_pool.name
    mode                 = each.value.default_node_pool.mode
    min_count            = each.value.default_node_pool.min_count
    max_count            = each.value.default_node_pool.max_count
    auto_scaling_enabled = each.value.default_node_pool.auto_scaling_enabled
    vm_size              = each.value.default_node_pool.vm_size
    os_disk_type         = each.value.default_node_pool.os_disk_type
    max_pods             = each.value.default_node_pool.max_pods
    zones                = each.value.default_node_pool.zones
    vnet_subnet_id       = each.value.default_node_pool.vnet_subnet_id
    pod_subnet_id        = each.value.default_node_pool.pod_subnet_id
    upgrade_settings = {
      max_surge                     = each.value.default_node_pool.upgrade_settings.max_surge
      drain_timeout_in_minutes      = each.value.default_node_pool.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = each.value.default_node_pool.upgrade_settings.node_soak_duration_in_minutes
    }
    only_critical_addons_enabled = each.value.default_node_pool.only_critical_addons_enabled
    temporary_name_for_rotation  = each.value.default_node_pool.temporary_name_for_rotation
    orchestrator_version         = each.value.default_node_pool.orchestrator_version
  }
  node_pools                          = each.value.node_pools
  dns_prefix                          = each.value.dns_prefix
  dns_prefix_private_cluster          = each.value.dns_prefix_private_cluster
  private_cluster_enabled             = each.value.private_cluster_enabled
  private_cluster_public_fqdn_enabled = each.value.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = each.value.private_dns_zone_id
  image_cleaner_enabled               = each.value.image_cleaner_enabled
  local_account_disabled              = each.value.local_account_disabled
  managed_identities = {
    system_assigned            = each.value.managed_identities.system_assigned
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity[each.value.managed_identities.name].resource_id]
  }
  kubelet_identity = {
    client_id                 = module.avm-res-managedidentity-userassignedidentity[each.value.kubelet_identity.name].client_id
    object_id                 = module.avm-res-managedidentity-userassignedidentity[each.value.kubelet_identity.name].principal_id
    user_assigned_identity_id = module.avm-res-managedidentity-userassignedidentity[each.value.kubelet_identity.name].resource_id
  }
  network_profile                   = each.value.network_profile
  role_based_access_control_enabled = each.value.role_based_access_control_enabled
  run_command_enabled               = each.value.run_command_enabled
  sku_tier                          = each.value.sku_tier
  diagnostic_settings               = each.value.diagnostic_settings
  # Add-Ons
  azure_policy_enabled       = each.value.azure_policy_enabled
  cost_analysis_enabled      = each.value.cost_analysis_enabled
  key_vault_secrets_provider = each.value.key_vault_secrets_provider
  monitor_metrics            = each.value.monitor_metrics
  oidc_issuer_enabled        = each.value.oidc_issuer_enabled
  workload_identity_enabled  = each.value.workload_identity_enabled
  oms_agent                  = each.value.oms_agent
  tags                       = var.tags
}
