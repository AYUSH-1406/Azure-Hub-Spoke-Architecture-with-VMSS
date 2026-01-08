resource "azurerm_network_security_group" "this" {
  name                = "${var.project_name}-${var.environment}-${var.nsg_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-Bastion-SSH-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"

    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["22", "3389"]
  }

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
