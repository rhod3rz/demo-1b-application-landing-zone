#================================================================================================
# Environment Configuration Values (e.g. dev.tfvars)
#================================================================================================
variable "subscription_id" {
  description = "The subscription id."
  type        = string
}
variable "subscription_id_management" {
  description = "The subscription id of the management sub required to pull key vault secrets."
  type        = string
}
variable "tenant_id" {
  description = "The tenant id."
  type        = string
}
variable "location" {
  description = "The location to deploy resources."
  type        = string
}
variable "enable_telemetry" {
  description = "Do you want to enable telemetry."
  type        = bool
}
variable "tags" {
  description = "A map of the environment specific tags which are merged into resource tags."
  type        = map(string)
}

#================================================================================================
# 010-avm-res-managedidentity-userassignedidentity.tf
#================================================================================================
variable "uamis" {
  description = "A map of user assigned managed identities to create."
  type        = any
}
variable "uami_role_assignments_resource" {
  description = "A map of user assigned managed identity role assignments to create - resource targetted."
  type        = any
}
variable "uami_role_assignments_resource_groups" {
  description = "A map of user assigned managed identity role assignments to create - resource group targetted."
  type        = any
}

#================================================================================================
# 020-avm-res-keyvault-vault.tf
#================================================================================================
variable "key_vaults" {
  description = "A map of keyvaults to create."
  type        = any
}
variable "secrets" {
  description = "A map of secrets to create."
  type        = any
}

#================================================================================================
# 030-avm-res-containerregistry-registry.tf
#================================================================================================
variable "container_registrys" {
  description = "A map of container registries to create."
  type        = any
}

#================================================================================================
# 040-avm-res-containerservice-managedcluster.tf
#================================================================================================
variable "nat_gateway" {
  description = "To lookup the ip prefix if nat gateway is in use."
  type        = any
}
variable "clusters" {
  description = "A map of aks clusters to create."
  type        = any
}

#================================================================================================
# 050-federated-identitys.tf
#================================================================================================
variable "federated_identitys" {
  description = "A map of federated identitys to create."
  type        = any
}

#================================================================================================
# 060-agfc.tf
#================================================================================================
variable "gateways" {
  description = "A map of agfc gateways to create."
  type        = any
}
