#================================================================================================
# Environment Configuration Values (e.g. dev.tfvars)
#================================================================================================
variable "subscription_id" {
  description = "The subscription id."
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
# 010-front-door.tf
#================================================================================================
variable "front_door_profiles" {
  description = "A map of front door profiles to create."
  type        = any
}
variable "front_door_endpoints" {
  description = "A map of front door endpoints to create."
  type        = any
}
