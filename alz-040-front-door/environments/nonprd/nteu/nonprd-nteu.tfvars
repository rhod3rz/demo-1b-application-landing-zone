#================================================================================================
# Environment Configuration Values
#================================================================================================
subscription_id  = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05" # appl_prd_01.
location         = "northeurope"
enable_telemetry = false
tags = {
  environment = "nonprd"
  owner       = "rhod3rz@outlook.com"
}

#================================================================================================
# 010-front-door.tf
#================================================================================================
front_door_profiles = {
  fd-prd-01 = {
    resource_group_name = "rg-nonprd-nteu-aks"
    sku_name            = "Standard_AzureFrontDoor"
  }
}
front_door_endpoints = {}

# nonprd has its own tfvars as the environments arent called nonprd, but dev and tst.
# prd has it all in one as prd for frontdoor is the same as prd for aks.
