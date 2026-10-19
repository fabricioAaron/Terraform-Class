# local sirve para crear variables globales. en el caso de nsg_rules es una lista de reglas de seguridad que se van a crear.
locals {
  nsg_rules = [

    {
      name                       = "allow-http"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "${azurerm_public_ip.mypublicIP.id}" # con esto se asocia ip del balanceador al nsg. 
      destination_address_prefix = "*"
    },

    {
      name                       = "allow-https"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "${azurerm_public_ip.mypublicIP.id}"
      destination_address_prefix = "*"
    },

    {
      name                       = "allow-ssh"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "${azurerm_public_ip.mypublicIP.id}"
      destination_address_prefix = "*"
    },
    {
      name                       = "denny-all"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

  ]
}
