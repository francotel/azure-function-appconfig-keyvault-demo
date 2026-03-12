
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-${azurerm_key_vault.main.name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private-subnet.id

  private_service_connection {
    name                           = "psc-keyvault"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "appconfig" {
  name                = "pe-${azurerm_app_configuration.appconfig.name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private-subnet.id

  private_service_connection {
    name                           = "psc-appconfig"
    private_connection_resource_id = azurerm_app_configuration.appconfig.id
    is_manual_connection           = false
    subresource_names              = ["configurationStores"]
  }

  tags = var.tags
}

