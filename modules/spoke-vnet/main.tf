resource "azurerm_virtual_network" "spoke" {
  name                = "${var.project_name}-${var.environment}-vnet-spoke-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.1.0.0/16"]

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}
