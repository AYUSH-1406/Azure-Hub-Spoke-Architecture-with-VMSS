resource "azurerm_monitor_action_group" "email" {
  name                = "${var.project_name}-${var.environment}-ag-core"
  resource_group_name = var.resource_group_name
  short_name          = "coreag"

  email_receiver {
    name          = "primary"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "vmss_cpu_high" {
  name                = "${var.project_name}-${var.environment}-vmss-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.vmss_id]
  severity            = 2
  enabled             = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 35
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}
