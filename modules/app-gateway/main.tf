resource "azurerm_public_ip" "this" {
  name                = "${var.project_name}-${var.environment}-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = "${var.project_name}-${var.environment}-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

    ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }


  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

#   backend_address_pool {
#   name         = "ilb-backend"
#   ip_addresses = [var.backend_ip]
# }

backend_address_pool {
  name  = "ilb-backend"
  fqdns = ["app.internal.local"]
}

  backend_http_settings {
    name                  = "http-settings"
    protocol              = "Http"
    port                  = 80
    cookie_based_affinity = "Disabled"
    request_timeout       = 30
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "ilb-backend"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }
}
