output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "shared_subnet_id" {
  value = azurerm_subnet.shared.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw.id
}
