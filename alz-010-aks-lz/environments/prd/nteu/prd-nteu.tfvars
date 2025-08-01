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
# 010-avm-res-resources-resourcegroup.tf
#================================================================================================
resource_groups = {
  rg-prd-nteu-aks = {
    role_assignments = {
      # assign all aks roles at the rg level so access can be controlled by entra group membership.
      # ==================
      # AZURE PORTAL ROLES
      # ==================
      # roles that allocate permissions within the azure portal.
      ra1 = {
        role_definition_id_or_name       = "Azure Kubernetes Service Cluster Admin Role"
        principal_id                     = "d31292ba-8b85-4cea-a880-ac90c2e92b8b" # object id | az-aks-prd-cluster-admins.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra2 = {
        role_definition_id_or_name       = "Azure Kubernetes Service Cluster Monitoring User"
        principal_id                     = "0da9f913-9e99-4fcd-97b1-8e6e5eea89f3" # object id | az-aks-prd-cluster-monitoring.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra3 = {
        role_definition_id_or_name       = "Azure Kubernetes Service Cluster User Role"
        principal_id                     = "6ef80ba8-990f-4a31-a404-4176b152c872" # object id | az-aks-prd-cluster-users.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra4 = {
        role_definition_id_or_name       = "Azure Kubernetes Service Contributor Role"
        principal_id                     = "a7ec1ace-7e9b-4e9e-a767-e9a405a6014d" # object id | az-aks-prd-cluster-contributors.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      # ======================
      # AKS CLUSTER WIDE ROLES
      # ======================
      # roles that allocate permissions within the aks cluster | role bindings will automatically be created for anything in here.
      ra5 = {
        role_definition_id_or_name       = "Azure Kubernetes Service RBAC Admin"
        principal_id                     = "58a8c322-f558-4119-8ea9-c80bb9f51e5a" # object id | k8s-aks-prd-rbac-admins.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra6 = {
        role_definition_id_or_name       = "Azure Kubernetes Service RBAC Cluster Admin"
        principal_id                     = "0f15d63f-c6d2-46bb-8111-04e22e54543f" # object id | k8s-aks-prd-rbac-cluster-admins.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra7 = {
        role_definition_id_or_name       = "Azure Kubernetes Service RBAC Reader"
        principal_id                     = "7eaea1f9-9a25-40ab-9a4a-6b4dff412c2f" # object id | k8s-aks-prd-rbac-readers.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
      ra8 = {
        role_definition_id_or_name       = "Azure Kubernetes Service RBAC Writer"
        principal_id                     = "f307d13e-6a34-4d6d-a89a-51fdb3e9ddb1" # object id | k8s-aks-prd-rbac-writers.
        skip_service_principal_aad_check = false                                  # set to 'true' for service principals.
      }
    }
  }
}

#================================================================================================
# 020-avm-res-network-routetable.tf
#================================================================================================
route_tables = {
  route-snet-nteu-diags = {
    resource_group_name = "rg-prd-nteu-aks"
    routes              = {}
  }
  route-snet-nteu-blu-nodes = {
    resource_group_name = "rg-prd-nteu-aks"
    routes              = {}
  }
  route-snet-nteu-grn-nodes = {
    resource_group_name = "rg-prd-nteu-aks"
    routes              = {}
  }
  route-snet-nteu-blu-pods = {
    resource_group_name = "rg-prd-nteu-aks"
    routes              = {}
  }
  route-snet-nteu-grn-pods = {
    resource_group_name = "rg-prd-nteu-aks"
    routes              = {}
  }
}

#================================================================================================
# 030-avm-res-network-networksecuritygroup.tf
#================================================================================================
network_security_groups = {
  nsg-snet-nteu-pep = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-pep.csv"
  }
  nsg-snet-nteu-blu-agfc = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-blu-agfc.csv"
  }
  nsg-snet-nteu-grn-agfc = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-grn-agfc.csv"
  }
  nsg-snet-nteu-diags = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-diags.csv"
  }
  nsg-snet-nteu-blu-nodes = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-blu-nodes.csv"
  }
  nsg-snet-nteu-grn-nodes = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-grn-nodes.csv"
  }
  nsg-snet-nteu-blu-pods = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-blu-pods.csv"
  }
  nsg-snet-nteu-grn-pods = { # name must be lowercase.
    resource_group_name = "rg-prd-nteu-aks"
    security_rules      = "environments/prd/nteu/nsg-snet-nteu-grn-pods.csv"
  }
}

#================================================================================================
# 040-avm-res-network-natgateway.tf
#================================================================================================
nat_gws = {
  natgw-prd-nteu = {
    resource_group_name     = "rg-prd-nteu-aks"
    idle_timeout_in_minutes = 30
    public_ip_prefix_length = 31 # 28 = 16 addresses | 29 = 8 addresses | 30 = 4 addresses | 31 = 2 addresses
    public_ip_configuration = {
      allocation_method    = "Static"
      ddos_protection_mode = "VirtualNetworkInherited"
      ip_version           = "IPv4"
      sku                  = "Standard"
      sku_tier             = "Regional"
    }
  }
}

#================================================================================================
# 050-avm-res-network-virtualnetwork.tf
#================================================================================================
spokes = {
  vnet-prd-nteu-aks = {
    resource_group_name = "rg-prd-nteu-aks"
    name                = "vnet-prd-nteu-aks"
    address_space       = ["10.12.0.0/20"]
    subnets = {
      snet-nteu-pep = {
        subnet_name                     = "snet-nteu-pep"
        address_prefixes                = ["10.12.1.0/24"]
        assign_generated_route_table    = false
        route_table_name                = ""
        nat_gateway_name                = ""
        nsg_name                        = "nsg-snet-nteu-pep"
        default_outbound_access_enabled = false
        delegation                      = []
      }
      snet-nteu-blu-agfc = {
        subnet_name                     = "snet-nteu-blu-agfc"
        address_prefixes                = ["10.12.2.0/24"] # must be a /24 or bigger.
        assign_generated_route_table    = false
        route_table_name                = ""
        nat_gateway_name                = ""
        nsg_name                        = "nsg-snet-nteu-blu-agfc"
        default_outbound_access_enabled = false
        delegation = [
          {
            name = "agfc-delegation"
            service_delegation = {
              name    = "Microsoft.ServiceNetworking/trafficControllers"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        ]
      }
      snet-nteu-grn-agfc = {
        subnet_name                     = "snet-nteu-grn-agfc"
        address_prefixes                = ["10.12.3.0/24"] # must be a /24 or bigger.
        assign_generated_route_table    = false
        route_table_name                = ""
        nat_gateway_name                = ""
        nsg_name                        = "nsg-snet-nteu-grn-agfc"
        default_outbound_access_enabled = false
        delegation = [
          {
            name = "agfc-delegation"
            service_delegation = {
              name    = "Microsoft.ServiceNetworking/trafficControllers"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        ]
      }
      snet-nteu-diags = {
        subnet_name                     = "snet-nteu-diags"
        address_prefixes                = ["10.12.4.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-diags"
        nat_gateway_name                = "natgw-prd-nteu"
        nsg_name                        = "nsg-snet-nteu-diags"
        default_outbound_access_enabled = false
        delegation                      = []
      }
      snet-nteu-blu-nodes = {
        subnet_name                     = "snet-nteu-blu-nodes"
        address_prefixes                = ["10.12.6.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-blu-nodes"
        nat_gateway_name                = "natgw-prd-nteu"
        nsg_name                        = "nsg-snet-nteu-blu-nodes"
        default_outbound_access_enabled = false
        delegation                      = []
      }
      snet-nteu-grn-nodes = {
        subnet_name                     = "snet-nteu-grn-nodes"
        address_prefixes                = ["10.12.7.0/24"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-grn-nodes"
        nat_gateway_name                = "natgw-prd-nteu"
        nsg_name                        = "nsg-snet-nteu-grn-nodes"
        default_outbound_access_enabled = false
        delegation                      = []
      }
      snet-nteu-blu-pods = {
        subnet_name                     = "snet-nteu-blu-pods"
        address_prefixes                = ["10.12.8.0/22"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-blu-pods"
        nat_gateway_name                = "natgw-prd-nteu"
        nsg_name                        = "nsg-snet-nteu-blu-pods"
        default_outbound_access_enabled = false
        delegation = [
          {
            name = "pods-delegation"
            service_delegation = {
              name    = "Microsoft.ContainerService/managedClusters"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        ]
      }
      snet-nteu-grn-pods = {
        subnet_name                     = "snet-nteu-grn-pods"
        address_prefixes                = ["10.12.12.0/22"]
        assign_generated_route_table    = false
        route_table_name                = "route-snet-nteu-grn-pods"
        nat_gateway_name                = "natgw-prd-nteu"
        nsg_name                        = "nsg-snet-nteu-grn-pods"
        default_outbound_access_enabled = false
        delegation = [
          {
            name = "pods-delegation"
            service_delegation = {
              name    = "Microsoft.ContainerService/managedClusters"
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        ]
      }
    }
    role_assignments = {
      # requirement to link the vnet to private dns zones.
      ra1 = {
        principal_id               = "b53b1efb-765f-412c-82a9-3edd8d0a7e47" # enterprise application > object id | sp_conn_prd_01.
        role_definition_id_or_name = "Private DNS Zone Contributor"
      }
    }
  }
}

#================================================================================================
# 060-avm-res-network-virtualnetwork-peering.tf
#================================================================================================
vnet_peerings = {
  northprd_to_northhub = {
    virtual_network                      = "vnet-prd-nteu-aks"
    remote_subscription_id               = "6e71165a-aad7-4b08-ba1b-628e397e4b18" # conn_prd_01.
    remote_resource_group                = "rg-prd-nteu-hub"
    remote_virtual_network_name          = "vnet-prd-nteu-hub"
    name                                 = "northprd-to-northhub"
    allow_virtual_network_access         = true  # enable access between vnets.
    allow_forwarded_traffic              = true  # allow traffic forwarding for inter vnet communication.
    allow_gateway_transit                = false # west vnet doesnt act as a transit gateway (e.g. no vpn or expressroute gateway).
    use_remote_gateways                  = false # west vnet doesnt need to use a transit gateway in north.
    create_reverse_peering               = true  # set up reverse peering automatically.
    reverse_name                         = "northhub-to-northprd"
    reverse_allow_virtual_network_access = true  # enable access between vnets.
    reverse_allow_forwarded_traffic      = true  # allow traffic forwarding for inter vnet communication.
    reverse_allow_gateway_transit        = false # north vnet doesnt act as a transit gateway (e.g. no vpn or expressroute gateway).
    reverse_use_remote_gateways          = false # north vnet doesnt need to use a transit gateway in west.
  }
}

#================================================================================================
# 070-avm-res-compute-virtualmachine.tf
#================================================================================================
key_vault_name = "kv-prd-nteu"
key_vault_rg   = "rg-prd-nteu-mgmt"
virtual_machines = {
  # basic linux 'ping' vm to test spoke to spoke connectivity.
  vm-10-12-3-99 = {
    resource_group_name               = "rg-prd-nteu-aks"
    os_type                           = "Linux"
    sku_size                          = "Standard_B1s" # 1vCPU, 1GB.
    zone                              = "1"
    disable_password_authentication   = false
    admin_username                    = "ladmin"
    boot_diagnostics                  = true
    enable_automatic_updates          = false
    secure_boot_enabled               = false
    vtpm_enabled                      = false
    vm_agent_platform_updates_enabled = false
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts"
      version   = "latest"
    }
    os_disk = {
      storage_account_type     = "StandardSSD_LRS"
      name                     = "vm-10-12-3-99-osdisk"
      caching                  = "ReadWrite"
      security_encryption_type = null
    }
    nic_create_public_ip_address  = false
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.12.3.99"
    private_ip_vnet_name          = "vnet-prd-nteu-aks"
    private_ip_subnet_name        = "snet-nteu-diags"
    shutdown_schedules = {
      test_schedule = {
        daily_recurrence_time = "1900"
        enabled               = true
        timezone              = "GMT Standard Time"
      }
    }
  }
}
