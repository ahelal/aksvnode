
resource "azurerm_route_table" "route" {
  name                = format("%s-routetable", var.prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = format("%s-vnet", var.prefix)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = "10.1.0.0/24"
  virtual_network_name = azurerm_virtual_network.vnet.name
}
resource "azurerm_subnet" "aci" {
  name                 = "virtual"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = "10.1.1.0/24"
  virtual_network_name = azurerm_virtual_network.vnet.name
  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}


resource "azurerm_subnet_route_table_association" "route" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.route.id
}
