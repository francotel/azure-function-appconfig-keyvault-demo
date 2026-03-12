resource "azurerm_app_configuration" "appconfig" {
  name                       = "app-config-${resource.random_pet.pet-name.id}-${var.env}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  sku                        = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 1
  tags                       = var.tags
}