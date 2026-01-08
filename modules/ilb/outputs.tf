output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.backend.id
}

output "ilb_name" {
  value = azurerm_lb.internal.name
}

output "private_ip" {
  value = azurerm_lb.internal.frontend_ip_configuration[0].private_ip_address
}
output "lb_id" {
  value = azurerm_lb.internal.id
}
