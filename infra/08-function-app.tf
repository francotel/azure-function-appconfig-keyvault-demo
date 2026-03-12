# Step 8: Function App (initial creation)
# resource "azurerm_linux_function_app" "main" {
#   name                = "func-${var.project-name}-${resource.random_pet.pet-name.id}-${var.env}"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location

#   storage_account_name       = azurerm_storage_account.functions.name
#   storage_account_access_key = azurerm_storage_account.functions.primary_access_key
#   service_plan_id            = azurerm_service_plan.functions.id

#   site_config {
#     http2_enabled   = true
#     always_on       = false
#     app_scale_limit = 1
#     application_stack {
#       node_version = "24"
#     }
#     cors {
#       allowed_origins = ["https://portal.azure.com"]
#     }
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = var.tags
# }

 