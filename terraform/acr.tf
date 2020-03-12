
resource "azurerm_container_registry" "acr" {
  name                     = format("%sacr", var.prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                      = "Basic"
  admin_enabled            = true
}

output "acr_server" {
  value = azurerm_container_registry.acr.login_server
}

output "docker_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "docker_password" {
  value = azurerm_container_registry.acr.admin_password
}
