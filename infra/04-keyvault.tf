resource "azurerm_key_vault" "main" {
  name                       = "kv-${resource.random_pet.pet-name.id}-${var.env}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

# resource "azurerm_key_vault" "kv" {
#   name                        = var.keyvault_name
#   location                    = azurerm_resource_group.rg.location
#   resource_group_name         = azurerm_resource_group.rg.name
#   sku_name                    = "standard"
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 0
#   purge_protection_enabled    = false

#   network_acls {
#     default_action = "Deny"
#     bypass         = "AzureServices"
#   }
# }



  