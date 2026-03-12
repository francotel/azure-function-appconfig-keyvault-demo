resource "random_pet" "pet-name" {
  length = 1
}

data "azurerm_client_config" "current" {}

# # Resource Group
# resource "azurerm_resource_group" "main" {
#   name     = "rg-${var.project}-${resource.random_pet.pet-name.id}"
#   location = var.location
#   tags     = var.tags
# }

# resource "azurerm_app_configuration" "app-config" {
#   name                       = "app-config-${resource.random_pet.pet-name.id}"
#   resource_group_name        = azurerm_resource_group.main.name
#   location                   = azurerm_resource_group.main.location
#   sku                        = "standard"
#   purge_protection_enabled   = false
#   soft_delete_retention_days = 1
#   tags                       = var.tags
# }

# resource "azurerm_resource_provider_registration" "app-config-registration" {
#   name = "Microsoft.AppConfiguration"
# }

# resource "azurerm_resource_provider_registration" "vnet-registration" {
#   name = "Microsoft.Network"
# }