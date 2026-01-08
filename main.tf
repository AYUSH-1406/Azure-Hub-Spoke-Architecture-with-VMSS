resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "hub_vnet" {
  source              = "./modules/hub-vnet"
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

module "spoke_vnet" {
  source              = "./modules/spoke-vnet"
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

# Hub → Spoke Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "${var.project_name}-${var.environment}-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.hub_vnet.vnet_name
  remote_virtual_network_id = module.spoke_vnet.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Spoke → Hub Peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${var.project_name}-${var.environment}-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = module.spoke_vnet.vnet_name
  remote_virtual_network_id = module.hub_vnet.vnet_id

  allow_virtual_network_access = true
}

module "bastion" {
  source              = "./modules/bastion"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.hub_vnet.bastion_subnet_id
}

module "hub_nsg" {
  source              = "./modules/nsg"
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  nsg_name            = "hub-shared-nsg"
}

module "spoke_nsg" {
  source              = "./modules/nsg"
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  nsg_name            = "app-subnet-nsg"
}

resource "azurerm_subnet_network_security_group_association" "hub_shared" {
  subnet_id                 = module.hub_vnet.shared_subnet_id
  network_security_group_id = module.hub_nsg.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "spoke_app" {
  subnet_id                 = module.spoke_vnet.app_subnet_id
  network_security_group_id = module.spoke_nsg.nsg_id
}

module "spoke_vmss" {
  source              = "./modules/vmss"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.spoke_vnet.app_subnet_id
  admin_username      = "azureuser"
  instance_count      = 2
  backend_pool_id     = module.internal_lb.backend_pool_id
}


module "internal_lb" {
  source              = "./modules/ilb"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.spoke_vnet.app_subnet_id
}

# Nat
resource "azurerm_public_ip" "nat" {
  name                = "${var.project_name}-${var.environment}-nat-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
resource "azurerm_nat_gateway" "this" {
  name                = "${var.project_name}-${var.environment}-nat"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}
resource "azurerm_subnet_nat_gateway_association" "spoke" {
  subnet_id      = module.spoke_vnet.app_subnet_id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

module "alerting_phase7a" {
  source              = "./modules/alerting"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vmss_id             = module.spoke_vmss.vmss_id
  alert_email         = "ayushsri1406@gmail.com"
}

module "app_gateway" {
  source              = "./modules/app-gateway"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.hub_vnet.appgw_subnet_id
  backend_ip          = module.internal_lb.private_ip
}

module "private_dns" {
  source              = "./modules/private-dns"
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = azurerm_resource_group.rg.name

  zone_name = "internal.local"

  records = {
    app = module.internal_lb.private_ip
  }

  vnet_ids = [
    module.hub_vnet.vnet_id,
    module.spoke_vnet.vnet_id
  ]
}
