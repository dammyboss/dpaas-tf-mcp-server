terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117, < 5.0"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
provider "azurerm" {
  subscription_id = "dbcd4abc-9638-497f-bab3-c6575bd67b72"
  features {}

}
