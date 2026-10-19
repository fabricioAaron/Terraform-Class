resource "azurerm_monitor_autoscale_setting" "autoescala" {
  name                = "myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.vmss_terraform_tutorial.id

  profile {
    name = "autoescalado"
    capacity {
      default = 2
      minimum = 1
      maximum = 5
    }
    # regal si la CPU es mayor al 80% durante 10 minutos, se agregara una instancia.  
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss_terraform_tutorial.id
        time_grain         = "PT1M"
        time_window        = "PT10M" # indica que la metrica se va a tomar en un intervalo de 10 minutos
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 80

      }
      # si el porcentaje de CPU es mayor al 80% durante 10 minutos, se agregara una instancia.  
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1" # indica que va incrementar en 1 mv el escalado
        cooldown  = "PT10M"

      }

    }
    # CPU < 10 % elimina vm
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss_terraform_tutorial.id
        time_grain         = "PT1M"
        time_window        = "PT10M" # indica que la metrica se va a tomar en un intervalo de 10 minutos
        time_aggregation   = "Average"
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 10
      }
      # si el porcentaje de CPU es menor al 80% durante 10 minutos, se agregara una instancia.  
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1" # indica que va disminuir en 1 mv el escalado
        cooldown  = "PT10M"
      }
    }
  }

}
