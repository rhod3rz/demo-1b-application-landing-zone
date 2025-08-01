#================================================================================================
# Provider Configuration
#================================================================================================
terraform {
  # https://developer.hashicorp.com/terraform/language/expressions/version-constraints
  # https://developer.hashicorp.com/terraform/language/v1-compatibility-promises
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0, >= 2.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
  # We don't specify config here as different state files are required per environment.
  # This is done in the pipeline.
  backend "azurerm" {
  }
}

provider "azurerm" {
  # We include subscription_id in here as different environments may be in different subscriptions.
  subscription_id = var.subscription_id
  features {}
}

provider "azurerm" {
  # Adding an alias to the management subscription to pull down key vault secrets.
  alias           = "management"
  subscription_id = var.subscription_id_management
  features {}
}
