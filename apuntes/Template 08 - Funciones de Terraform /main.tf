locals {
  formatted_name = replace(var.proyecto_name, " ", "-")
}

resource "azurerm_resource_group" "rg" {
  name = local.formatted_name
  location = "spain central"
  
}

output "rgname" {
  value = azurerm_resource_group.rg.name
}