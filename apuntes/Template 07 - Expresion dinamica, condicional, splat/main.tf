resource "azurerm_resource_group" "rg" {
  name     = "example-resources"
  location = "spaincentral"
}

resource "azurerm_network_security_group" "rg" {
  name                = (var.environment == "dev" ? dev-nsg : stage-nsg) #aqui usamos una expresion condicional para definir el nombre de la regla de seguridad https://developer.hashicorp.com/terraform/language/expressions/conditionals
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {    #aquí se define un bloque dinámico que se va a ejecutar para cada elemento del mapa de reglas de seguridad siempre que va un dynamic se tiene que poner un content para definir el bloque que se va a ejecutarº
    for_each = local.nsg_rules #esto sirve para iterar cada uno de los elementos que tenemos en el local
    content {
      name                       = security_rule.key                          #aqui se define el nombre de la regla dentro de local sería nuestro allow-http, allow-https
      priority                   = security_rule.value.priority               #aqui se define la prioridad de la regla es un mapa anidado
      direction                  = "Inbound"                                  #aqui se define la dirección de la regla
      access                     = "Allow"                                    #aqui se define el acceso de la regla
      protocol                   = "Tcp"                                      #aqui se define el protocolo de la regla
      source_port_range          = "*"                                        #aqui se define el puerto de origen de la regla
      destination_port_range     = security_rule.value.destination_port_range #aqui se define el puerto de destino de la regla
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = security_rule.value.description
    }
  }

  tags = {
    environment = "Production"
  }
}
