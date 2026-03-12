resource "azurerm_service_plan" "functions" {
  name                         = "asp-${var.project-name}-${resource.random_pet.pet-name.id}-${var.env}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  os_type                      = "Linux"
  sku_name                     = "FC1"
  maximum_elastic_worker_count = 1
  tags                         = var.tags
}