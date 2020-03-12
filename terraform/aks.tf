resource "azurerm_resource_group" "rg" {
  name     = format("%s-aks", var.prefix)
  location = "West Europe"
  depends_on = [
    azuread_service_principal_password.password,
    azurerm_role_assignment.rbac
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksvnode"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksvnode"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  service_principal {
    client_id     = azuread_service_principal.spn.application_id
    client_secret = random_string.password.result
  }
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }
  addon_profile {
    aci_connector_linux {
      enabled     = true
      subnet_name = azurerm_subnet.aci.name
    }
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_rg" {
  value = azurerm_resource_group.rg.name
}

