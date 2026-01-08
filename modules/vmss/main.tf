resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.project_name}-${var.environment}-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_B2ats_v2"
  instances           = var.instance_count
  admin_username      = var.admin_username

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.root}/ssh-keys/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  # 🔐 NETWORK (ILB BACKEND)
  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = [
        var.backend_pool_id
      ]
    }
  }

  # 🚀 CLOUD-INIT (CUSTOM DATA)
  custom_data = base64encode(<<EOF
#cloud-config
package_update: true
packages:
  - nginx

write_files:
  - path: /var/www/html/index.html
    permissions: '0644'
    content: |
      <html>
      <head><title>VMSS via Custom Data</title></head>
      <body>
        <h1>NGINX running on VMSS</h1>
        <p>Project: ${var.project_name}</p>
        <p>Environment: ${var.environment}</p>
      </body>
      </html>

runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
EOF
  )

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
