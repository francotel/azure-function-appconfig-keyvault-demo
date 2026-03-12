resource "azurerm_storage_account" "functions" {
  name                     = "st${resource.random_pet.pet-name.id}${var.env}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
  lifecycle {
    prevent_destroy = false
  }
}