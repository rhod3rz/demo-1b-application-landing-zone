# 100% - upgrades work with zero downtime e.g. create a new node, move pods to it then move onto the next one.
# cni-overlay + nat gateway | Network Configuration : Azure CNI Overlay
# Nodes = from dedicated byo subnet e.g. snet-nteu-blu-nodes
# Pods  = from an auto-created overlay subnet e.g. pod_cidr = "192.168.0.0/16"

#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id            = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05" # appl_prd_01.
subscription_id_management = "21c8877e-a2da-4483-8ada-25856954e76b" # mana_prd_01 | required to pull key vault secrets.
tenant_id                  = "73578441-dc3d-4ecd-a298-fc5c6f40e191"
location                   = "northeurope"
enable_telemetry           = false
tags = {
  environment = "prd"
  owner       = "rhod3rz@outlook.com"
}

#================================================================================================
# 010-avm-res-managedidentity-userassignedidentity.tf
#================================================================================================
uamis = {
  # a uami is required to deploy a private cluster; the uami must be given permissions to update the dns zone.
  # the same uami can also be used for application gateway for containers (agfc).
  # blue & green clusters must have their own unique uami because they each need a federated identity called 'azure-alb-identity'.
  uami-aks-prd-nteu-blu = {
    resource_group_name = "rg-prd-nteu-aks"
  }
}

# assign rbac to resources.
uami_role_assignments_resource = {
  # assign 'uami-aks-prd-nteu-blu' uami 'Private DNS Zone Contributor' role to privatelink.northeurope.azmk8s.io.
  uami-aks-prd-nteu-blu-to-dns = {
    uami_name = "uami-aks-prd-nteu-blu"
    # target
    subscription_id      = "6e71165a-aad7-4b08-ba1b-628e397e4b18"
    resource_group_name  = "rg-prd-pdns"
    resource_type        = "Microsoft.Network/privateDnsZones"
    resource_name        = "privatelink.northeurope.azmk8s.io"
    role_definition_name = "Private DNS Zone Contributor"
  }
  # assign 'uami-aks-prd-nteu-blu' uami 'Network Contributor' role to snet-nteu-agfc - required for agfc.
  uami-aks-prd-nteu-blu-to-agfc-subnet = {
    uami_name = "uami-aks-prd-nteu-blu"
    # target
    subscription_id      = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
    resource_group_name  = "rg-prd-nteu-aks"
    resource_type        = "Microsoft.Network/virtualNetworks"
    resource_name        = "vnet-prd-nteu-aks/subnets/snet-nteu-blu-agfc"
    role_definition_name = "Network Contributor"
  }
  # assign permission to itself to prevent errors when using the uami for the kubelet identity.
  uami-aks-prd-nteu-blu-on-self = {
    uami_name = "uami-aks-prd-nteu-blu"
    # target
    subscription_id      = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
    resource_group_name  = "rg-prd-nteu-aks"
    resource_type        = "Microsoft.ManagedIdentity/userAssignedIdentities"
    resource_name        = "uami-aks-prd-nteu-blu"
    role_definition_name = "Managed Identity Operator"
  }
}

# assign rbac to resource groups.
uami_role_assignments_resource_groups = {
  # assign 'uami-aks-prd-nteu-blu' uami 'Reader' role to resource group - required for agfc.
  uami-aks-prd-nteu-blu-reader-to-rg = {
    uami_name = "uami-aks-prd-nteu-blu"
    # target
    subscription_id      = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
    resource_group_name  = "rg-prd-nteu-aks"
    role_definition_name = "Reader"
  }
  # assign 'uami-aks-prd-nteu-blu' uami 'AppGw for Containers Configuration Manager' role to resource group - required for agfc.
  uami-aks-prd-nteu-appgw-to-rg = {
    uami_name = "uami-aks-prd-nteu-blu"
    # target
    subscription_id      = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
    resource_group_name  = "rg-prd-nteu-aks"
    role_definition_name = "AppGw for Containers Configuration Manager"
  }
}

#================================================================================================
# 020-avm-res-keyvault-vault.tf
#================================================================================================
key_vaults = {
  kv-aks-prd-nteu = {
    resource_group_name           = "rg-prd-nteu-aks"
    public_network_access_enabled = true
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
      ip_rules       = ["86.10.95.19/32"]
      # 86.10.95.19/32 = rhodri home
      virtual_network_subnet_ids = []
    }
    private_endpoints = {
      # default = {
      #   resource_group_name             = "rg-prd-nteu-aks"
      #   name                            = "kv-aks-prd-nteu-pe"
      #   private_service_connection_name = "kv-aks-prd-nteu-psc"
      #   network_interface_name          = "kv-aks-prd-nteu-nic"
      #   subnet_resource_id              = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-nteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-aks/subnets/snet-nteu-pep"
      #   private_dns_zone_group_name     = "default"
      #   private_dns_zone_resource_ids   = ["/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-pdns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
      # }
    }
    purge_protection_enabled = false # set to true for production environment.
    role_assignments = {
      ra1 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id_or_uami_name        = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Key Vault Administrator"
        principal_id_or_uami_name        = "cb7d960f-bbe7-44c3-9c09-d64ec7c4bd26" # object id | rhodri.freer.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "Key Vault Secrets User"
        principal_id_or_uami_name        = "uami-aks-prd-nteu-blu" # name of the uami to resolve via the locals block.
        skip_service_principal_aad_check = true
      }
    }
    sku_name                   = "standard"
    soft_delete_retention_days = "7"
    diagnostic_settings = {
      # diags = {
      #   name                           = "diags"
      #   workspace_resource_id          = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu"
      #   log_groups                     = ["allLogs", "audit"]
      #   metric_categories              = ["AllMetrics"]
      #   log_analytics_destination_type = "Dedicated"
      # }
    }
  }
}
secrets = {
  kvTestSecret1 = {
    key_vault_name   = "kv-aks-prd-nteu"
    length           = 10
    value_wo_version = 1
  }
  kvTestSecret2 = {
    key_vault_name   = "kv-aks-prd-nteu"
    length           = 10
    value_wo_version = 1
  }
}

#================================================================================================
# 030-avm-res-containerregistry-registry.tf
#================================================================================================
container_registrys = {
  acrprdrhod3rz = {
    resource_group_name           = "rg-prd-nteu-aks"
    sku                           = "Basic"
    public_network_access_enabled = true
    private_endpoints = {
      # default = {
      #   resource_group_name             = "rg-prd-nteu-aks"
      #   name                            = "acrprdrhod3rz-pe"
      #   private_service_connection_name = "acrprdrhod3rz-psc"
      #   network_interface_name          = "acrprdrhod3rz-nic"
      #   subnet_resource_id              = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-nteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-aks/subnets/snet-nteu-pep"
      #   private_dns_zone_group_name     = "default"
      #   private_dns_zone_resource_ids   = ["/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-pdns/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"]
      # }
    }
    georeplications            = []
    network_rule_bypass_option = "AzureServices"
    zone_redundancy_enabled    = false
    retention_policy_in_days   = null # can only set for premium sku.
    role_assignments = {
      ra1 = {
        role_definition_id_or_name       = "AcrPull"
        principal_id_or_uami_name        = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "AcrPush"
        principal_id_or_uami_name        = "3a386d84-7142-4085-88ad-e8045ef940ea" # enterprise application > object id | sp_appl_prd_01.
        skip_service_principal_aad_check = true                                   # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "AcrPull"
        principal_id_or_uami_name        = "cb7d960f-bbe7-44c3-9c09-d64ec7c4bd26" # object id | rhodri.freer.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra4 = {
        role_definition_id_or_name       = "AcrPush"
        principal_id_or_uami_name        = "cb7d960f-bbe7-44c3-9c09-d64ec7c4bd26" # object id | rhodri.freer.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra5 = {
        role_definition_id_or_name       = "AcrPull"
        principal_id_or_uami_name        = "uami-aks-prd-nteu-blu" # name of the uami to resolve via the locals block.
        skip_service_principal_aad_check = true
      }
    }
    diagnostic_settings = {
      # diags = {
      #   name                           = "diags"
      #   workspace_resource_id          = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu"
      #   log_groups                     = ["allLogs", "audit"]
      #   metric_categories              = ["AllMetrics"]
      #   log_analytics_destination_type = "Dedicated"
      # }
    }
    # populate this if you want to upload sample demo apps to acr for initial testing.
    demoapps = {
      mango-cart = {
        name   = "acrprdrhod3rz"
        source = "docker.io/rhod1z/demoapp-1-tier-python:latest"
        image  = "mango-cart:latest"
      }
      mango-catalog = {
        name   = "acrprdrhod3rz"
        source = "docker.io/rhod1z/demoapp-1-tier-python:latest"
        image  = "mango-catalog:latest"
      }
    }
  }
}

#================================================================================================
# 040-avm-res-containerservice-managedcluster.tf
#================================================================================================
nat_gateway = { # if nat gateway is used populate details below; if using azure firewall set to null.
  name           = "natgw-prd-nteu"
  resource_group = "rg-prd-nteu-aks"
}
clusters = {
  aks-prd-nteu-blu = {
    resource_group_name      = "rg-prd-nteu-aks"
    node_resource_group_name = "rg-prd-nteu-aks-blu-nrg"
    api_server_access_profile = {
      # using the kubernetes or helm provider does not play well with setting api_server_access_profile :-(
      # once a firewall rule is set on the api, the kubernetes and helm jobs start to fail; despite having correct rules in place.
      # as such aks bootstrapping isnt done with terraform, but is moved to 071-aks-bootstrap.
      authorized_ip_ranges = ["86.10.95.19/32"] # if using azure firewall; ensure to include the ip in here!
      # 86.10.95.19/32 = rhodri home
      # x.x.x.x/32     = azure firewall
    }
    automatic_upgrade_channel = null
    azure_active_directory_role_based_access_control = {
      azure_rbac_enabled     = true
      admin_group_object_ids = ["0f15d63f-c6d2-46bb-8111-04e22e54543f"] # object id | k8s-aks-prd-rbac-cluster-admins.
    }
    kubernetes_version              = "1.31" # this is the control plane only | dont specify the patch version!
    create_nodepools_before_destroy = true   # ensure you have enough node and subnet ip capacity to temporarily double up! | not an issue with cni overlay.
    # System Node Pool
    default_node_pool = {
      name                 = "system" # pool name must be less than or equal to 8 characters if create_before_destroy is selected to prevent name conflicts.
      mode                 = "System"
      min_count            = 2
      max_count            = 3
      auto_scaling_enabled = true
      vm_size              = "Standard_B2as_v2" # Standard_B2s_v2 | Standard_B2as_v2
      os_disk_type         = "Managed"          # use 'Ephemeral' when possible | Managed used here as only option with Standard B2.
      max_pods             = 100
      zones                = ["1", "2", "3"]
      vnet_subnet_id       = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-nteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-aks/subnets/snet-nteu-blu-nodes"
      pod_subnet_id        = null
      upgrade_settings = {
        max_surge                     = 1  # how many extra nodes can be temporarily added during an upgrade.
        drain_timeout_in_minutes      = 15 # max time to wait when draining pods from a node.
        node_soak_duration_in_minutes = 5  # how long aks waits after adding new nodes; e.g. allows time for monitoring agents, readiness probes etc.
      }
      only_critical_addons_enabled = true       # sets the taint 'CriticalAddonsOnly=true:NoSchedule'
      temporary_name_for_rotation  = "rtsystem" # must contain only lowercase letters and numbers and be between 1 and 12 characters in length.
      orchestrator_version         = "1.31"
    }
    # User Node Pool
    node_pools = {
      user = {
        name                 = "user" # pool name must be less than or equal to 8 characters if create_before_destroy is selected to prevent name conflicts.
        mode                 = "User"
        min_count            = 2
        max_count            = 3
        auto_scaling_enabled = true
        vm_size              = "Standard_B2as_v2" # Standard_B2s_v2 | Standard_B2as_v2
        os_disk_type         = "Managed"          # use 'Ephemeral' when possible | Managed used here as only option with Standard B2.
        max_pods             = 100
        zones                = ["1", "2", "3"]
        vnet_subnet_id       = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-nteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-aks/subnets/snet-nteu-blu-nodes"
        pod_subnet_id        = null
        upgrade_settings = {
          max_surge                     = 1  # how many extra nodes can be temporarily added during an upgrade.
          drain_timeout_in_minutes      = 15 # max time to wait when draining pods from a node.
          node_soak_duration_in_minutes = 5  # how long aks waits after adding new nodes; e.g. allows time for monitoring agents, readiness probes etc.
        }
        temporary_name_for_rotation = "rtuser" # must contain only lowercase letters and numbers and be between 1 and 12 characters in length.
        orchestrator_version        = "1.31"
        node_labels = {
          rdzpool = "user" # for scheduling pods onto the user node pool.
        }
      }
    }
    # Public Cluster Settings
    dns_prefix                          = "rdz"
    dns_prefix_private_cluster          = null # when 'dns_prefix_private_cluster' is set, 'dns_prefix' must not be set.
    private_cluster_enabled             = false
    private_cluster_public_fqdn_enabled = false
    private_dns_zone_id                 = ""
    # Private Cluster Settings
    # NOTE: this is not the same as creating a pep for something like key vault; you cannot specify where the private ip goes here.
    # dns_prefix                          = ""
    # dns_prefix_private_cluster          = "rdz" # when 'dns_prefix_private_cluster' is set, 'dns_prefix' must not be set.
    # private_cluster_enabled             = true
    # private_cluster_public_fqdn_enabled = true
    # private_dns_zone_id                 = "/subscriptions/6e71165a-aad7-4b08-ba1b-628e397e4b18/resourceGroups/rg-prd-pdns/providers/Microsoft.Network/privateDnsZones/privatelink.northeurope.azmk8s.io"
    image_cleaner_enabled  = false
    local_account_disabled = true
    # the managed identity used by the aks control plane to manage cluster resources e.g. dns, networking and interacting with other azure services.
    managed_identities = {
      system_assigned = false
      name            = "uami-aks-prd-nteu-blu"
    }
    # the managed identity used by the aks node pool (kubelet) to pull container images, attach managed disks and interact with azure apis on behalf of the nodes.
    kubelet_identity = {
      name = "uami-aks-prd-nteu-blu"
    }
    network_profile = {
      network_plugin      = "azure"
      network_policy      = "cilium" # when network_policy is set to cilium, the network_data_plane field must be set to cilium.
      network_data_plane  = "cilium" # when network_data_plane is set to cilium, one of either network_plugin_mode = "overlay" or pod_subnet_id must be specified.
      network_plugin_mode = "overlay"
      pod_cidr            = "192.168.0.0/16"
      load_balancer_sku   = "standard"               # set to "standard" when using userAssignedNATGateway | set to null when using userDefinedRouting.
      outbound_type       = "userAssignedNATGateway" # loadBalancer | userAssignedNATGateway | userDefinedRouting | for 'userDefinedRouting' route table next hop must be 'virtualappliance'.
      service_cidr        = "172.16.0.0/16"          # better option than the default 10.0.0.0/16 which may clash with existing.
      dns_service_ip      = "172.16.0.10"            # better option than the default 10.0.0.0/16 which may clash with existing.
    }
    role_based_access_control_enabled = true
    run_command_enabled               = true
    sku_tier                          = "Free"
    diagnostic_settings = {
      # diags = {
      #   name                           = "diags"
      #   workspace_resource_id          = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu"
      #   log_groups                     = []
      #   log_categories                 = ["kube-apiserver", "kube-audit-admin", "kube-controller-manager"] # recommended minimum.
      #   metric_categories              = []
      #   log_analytics_destination_type = "Dedicated"
      # }
    }
    # Add-Ons
    # azure policy
    azure_policy_enabled = true
    # cost analysis
    cost_analysis_enabled = false
    # key vault
    key_vault_secrets_provider = {
      secret_rotation_enabled = true
    }
    # managed prometheus | this is simpler to install manually post cluster deployment.
    monitor_metrics = null
    # workload identity / oidc
    oidc_issuer_enabled       = true
    workload_identity_enabled = true
    # azure monitor agent (ama)
    oms_agent = null
    # oms_agent = {
    #   log_analytics_workspace_id      = "/subscriptions/21c8877e-a2da-4483-8ada-25856954e76b/resourceGroups/rg-prd-nteu-mgmt/providers/Microsoft.OperationalInsights/workspaces/law-prd-nteu"
    #   msi_auth_for_monitoring_enabled = false
    #   # bug: when msi_auth_for_monitoring_enabled = false; the install creates a uami and uses that to connect to law | this works fine and logs are written.
    #   # bug: when msi_auth_for_monitoring_enabled = true;  no uami is created, and there is no support to specify it here | logs dont get written.
    #   # bug: this requires a support ticket with microsoft.
    # }
    # Use this kql query to confirm logs are getting generated | the 'ContainerLog' table only gets created when a pod is created thats outputing logs.
    # e.g. kubectl run logtest --image=busybox --restart=Never -- sh -c 'while true; do echo "ama is working $(date)"; sleep 5; done'
    # ContainerLog  | where TimeGenerated > ago(60m)
  }
}

#================================================================================================
# 050-federated-identity.tf
#================================================================================================
# federated identities are created within uamis | once created you can check 'federated credentials' within the uami.
federated_identitys = {
  # requirement for application gateway for containers.
  fi1 = {
    name                = "azure-alb-identity"                                       # unique federation name | must be called this!
    resource_group_name = "rg-prd-nteu-aks"                                          # uami resource group.
    parent_id           = "uami-aks-prd-nteu-blu"                                    # uami name.
    issuer              = "aks-prd-nteu-blu"                                         # aks cluster name.
    subject             = "system:serviceaccount:azure-alb-system:alb-controller-sa" # system:serviceaccount:<namespace>:<service-account-name>.
    audience            = ["api://AzureADTokenExchange"]
  }
  # sa-mango; the federated identity for the mango namespace | the sa must sit in the same namespace as the deployment | e.g. used for querying key vault.
  fi2 = {
    name                = "sa-mango"                                # unique federation name.
    resource_group_name = "rg-prd-nteu-aks"                         # uami resource group.
    parent_id           = "uami-aks-prd-nteu-blu"                   # uami name.
    issuer              = "aks-prd-nteu-blu"                        # aks cluster name.
    subject             = "system:serviceaccount:ns-mango:sa-mango" # system:serviceaccount:<namespace>:<service-account-name>.
    audience            = ["api://AzureADTokenExchange"]
  }
}

#================================================================================================
# 060-agfc.tf
#================================================================================================
gateways = {
  agfc-prd-nteu-blu = {
    resource_group_name = "rg-prd-nteu-aks"
    gateway_name        = "agfc-prd-nteu-blu"
    subnet_name         = "snet-nteu-blu-agfc"
    subnet_id           = "/subscriptions/2bc7b65e-18d6-42ae-afb2-e66d50be6b05/resourceGroups/rg-prd-nteu-aks/providers/Microsoft.Network/virtualNetworks/vnet-prd-nteu-aks/subnets/snet-nteu-blu-agfc"
    gateway_frontends = {
      # a frontend per root domain (max 5) e.g. rhod3rz.com, test3rz.com etc.
      rhod3rz-com = {
        dns_cname_records = {
          agfc-prd-blu-mango-cart = {
            name                = "agfc.prd.blu.mango.cart" # must be prefixed agfc as prd.blu.mango.cart will be used as a cname to frontdoor.
            zone_name           = "rhod3rz.com"
            resource_group_name = "rg-core-01"
            ttl                 = 300
          }
          agfc-prd-blu-mango-catalog = {
            name                = "agfc.prd.blu.mango.catalog" # must be prefixed agfc as prd.blu.mango.catalog will be used as a cname to frontdoor.
            zone_name           = "rhod3rz.com"
            resource_group_name = "rg-core-01"
            ttl                 = 300
          }
        }
      }
    }
  }
}
