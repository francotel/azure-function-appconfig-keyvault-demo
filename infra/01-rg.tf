resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project-name}-${resource.random_pet.pet-name.id}-${var.env}"
  location = var.location
  tags     = var.tags
}