resource "azurerm_private_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_a_record" "records" {
  for_each = var.records

  name                = each.key
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [each.value]
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = {
    for idx, vnet_id in var.vnet_ids :
    idx => vnet_id
  }

  name                  = "dns-link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = each.value
  registration_enabled = false
}
